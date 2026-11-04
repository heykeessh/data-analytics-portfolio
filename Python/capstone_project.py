"""Launch with python -m streamlit run capstone_project.py."""
import json

import altair as alt
import pandas as pd
import streamlit as st

from analysis_pipeline import ROOT, analyze


CHART_LABELS = {
    "monthly": ("Merchandise Revenue by Month", "Track estimated merchandise sales over time."),
    "channels": ("Merchandise Revenue by Sales Channel", "Compare Web, Mobile App, and Marketplace sales."),
    "order_values": ("Distribution of Order Values", "See how many revenue-bearing orders fall into each spending range."),
    "products": ("Top 10 Products by Merchandise Revenue", "Rank matched catalog products by sales in the selected period."),
    "categories": ("Merchandise Revenue by Product Category", "Compare sales across standardized product categories."),
    "regions": ("Merchandise Revenue by Customer Region", "Compare sales by the region recorded on each customer profile."),
    "cities": ("Top 10 Customer Cities by Merchandise Revenue", "Rank customer cities by sales in the selected period."),
    "customer_types": ("Merchandise Revenue by Customer Type", "Compare first observed orders and repeat orders."),
    "cancellation_rate": ("Order Cancellation Rate by Month", "Share of orders placed each month that are currently marked Cancelled."),
    "statuses": ("Order Volume by Status", "Count all selected orders by their current status."),
}
BLUE = "#2563EB"
NAVY = "#1E40AF"


@st.cache_data
def load_data(folder):
    fact = pd.read_csv(folder / "sales_fact.csv", parse_dates=["order_datetime"])
    orders = pd.read_csv(folder / "orders_clean.csv", parse_dates=["order_datetime"])
    regions = pd.read_csv(folder / "customers_clean.csv", usecols=["customer_id", "region_name"])
    orders = orders.merge(regions, on="customer_id", how="left", validate="many_to_one")
    orders["region_name"] = orders["region_name"].fillna("Unknown")
    return fact, orders


def month_label(month):
    return pd.Period(month, freq="M").strftime("%b %Y")


def filters(orders, categories):
    months = pd.period_range(orders.order_datetime.min(), orders.order_datetime.max(), freq="M").astype(str).tolist()
    channels = sorted(orders.sales_channel.dropna().unique())
    regions = sorted(orders.region_name.unique())
    full_period = (months[0], months[-1])


    def reset():
        for key in ("months", "channels", "regions", "categories"):
            st.session_state.pop(key, None)

    with st.container(border=True, key="report_filters"):
        heading, action = st.columns([4, 1], vertical_alignment="center")
        heading.markdown("#### Filter the report")
        action.button("Reset filters", on_click=reset, width="stretch")
        dates, product, channel, region = st.columns([1.35, 1.15, 1, 1])
        months_selected = dates.select_slider(
            "Order months", options=months, value=full_period, format_func=month_label, key="months"
        )
        categories_selected = product.multiselect(
            "Product categories", categories, key="categories", placeholder="All categories"
        )
        channels_selected = channel.multiselect(
            "Sales channels", channels, key="channels", placeholder="All channels"
        )
        regions_selected = region.multiselect(
            "Customer regions", regions, key="regions", placeholder="All regions"
        )
    return months_selected, categories_selected, channels_selected or channels, regions_selected or regions


def trend_chart(values, cancellation):
    data = values.rename("value").rename_axis("month").reset_index()
    data["month"] = pd.to_datetime(data["month"], format="%Y-%m")
    if cancellation:
        data["value"] = data["value"] / 100
    axis = alt.Axis(format=".0%" if cancellation else "~s", tickCount=5)
    color = NAVY if cancellation else BLUE
    base = alt.Chart(data).encode(
        x=alt.X("month:T", title=None, axis=alt.Axis(format="%b %y", tickCount=7, labelAngle=0)),
        y=alt.Y("value:Q", title="Cancellation rate" if cancellation else "Revenue (PHP)", axis=axis),
    )
    line = base.mark_line(color=color, strokeWidth=3, invalid="break-paths-show-domains")
    points = base.mark_circle(size=65, color=color, opacity=1).encode(tooltip=[
        alt.Tooltip("month:T", title="Order month", format="%B %Y"),
        alt.Tooltip("value:Q", title="Cancellation rate" if cancellation else "Revenue (PHP)",
                    format=".1%" if cancellation else ",.2f"),
    ])
    return (line + points).properties(height=290)


def order_value_chart(values):
    counts = pd.cut(values, bins=24).value_counts(sort=False)
    data = pd.DataFrame({
        "low": [max(0, interval.left) for interval in counts.index],
        "high": [interval.right for interval in counts.index],
        "orders": counts.to_numpy(),
    })
    return alt.Chart(data).mark_bar(color=BLUE, stroke="white").encode(
        x=alt.X("low:Q", title="Revenue per order (PHP)", axis=alt.Axis(format="~s", tickCount=5)),
        x2="high:Q",
        y=alt.Y("orders:Q", title="Orders", axis=alt.Axis(format=",d", tickCount=5)),
        tooltip=[alt.Tooltip("low:Q", title="From (PHP)", format=",.0f"),
                 alt.Tooltip("high:Q", title="To (PHP)", format=",.0f"),
                 alt.Tooltip("orders:Q", title="Orders", format=",d")],
    ).properties(height=260)


def ranking_chart(values, counts):
    data = values.rename("value").rename_axis("label").reset_index()
    # Rank is the row key so identical product names still display as separate bars.
    data["rank"] = list(range(len(data)))
    label_expression = f"{json.dumps(data['label'].tolist())}[datum.value]"
    measure = "Orders" if counts else "Revenue (PHP)"
    return alt.Chart(data).mark_bar(
        color=NAVY if counts else BLUE, cornerRadiusEnd=4, size=18,
    ).encode(
        y=alt.Y("rank:O", title=None, sort="ascending",
                axis=alt.Axis(labelExpr=label_expression, labelLimit=235, labelPadding=8)),
        x=alt.X("value:Q", title=measure, axis=alt.Axis(format=",d" if counts else "~s", tickCount=5)),
        tooltip=[alt.Tooltip("label:N", title="Name"),
                 alt.Tooltip("value:Q", title=measure, format=",d" if counts else ",.2f")],
    ).properties(height=max(180, 31 * len(data)))


def chart_card(metrics, key):
    title, description = CHART_LABELS[key]
    with st.container(border=True):
        st.markdown(f"#### {title}")
        st.caption(description)
        values = metrics[key]
        if key == "cities":
            values = values.head(10)
        if values.dropna().empty:
            st.info("No data for this selection.")
            return
        if key in {"monthly", "cancellation_rate"}:
            chart = trend_chart(values, cancellation=key == "cancellation_rate")
        elif key == "order_values":
            chart = order_value_chart(values)
        else:
            chart = ranking_chart(values, counts=key == "statuses")
        chart = chart.configure_view(stroke=None).configure_axis(
            labelFontSize=11, titleFontSize=11, labelColor="#354D60", titleColor="#354D60",
            gridColor="#DCE8FA", domain=False, ticks=False,
        )
        st.altair_chart(chart, width="stretch", theme=None)


def main():
    st.set_page_config(page_title="Retail Sales & Customer Insights", layout="wide")
    fact, orders = load_data(ROOT / "data" / "cleaned_datasets")
    st.html("""
        <style>
        .report-hero {
            background: linear-gradient(115deg, #102b64, #1e40af 72%, #2563eb);
            border-radius: 1rem;
            color: #fff;
            padding: 1.65rem 2rem;
            margin-bottom: .4rem;
        }
        .report-hero p { color: #dbeafe; margin: 0; }
        .report-hero .eyebrow {
            font-size: .75rem; font-weight: 700; letter-spacing: .13em;
        }
        .report-hero h1 {
            color: #fff; font-size: clamp(1.55rem, 3vw, 2.45rem);
            line-height: 1.15; margin: .35rem 0 .55rem; padding: 0;
        }
        .st-key-report_filters { background-color: #eff6ff; }
        .st-key-scorecard [data-testid="stMetricValue"] { color: #163d89; }
        </style>
        <header class="report-hero">
            <p class="eyebrow">RETAIL PERFORMANCE REPORT</p>
            <h1>Retail Sales &amp; Customer Insights</h1>
            <p>Merchandise revenue, customer behavior, and order operations</p>
        </header>
    """)
    categories = sorted(fact["category"].dropna().unique())
    (start, end), category_filter, channels, regions = filters(orders, categories)
    period = month_label(start) if start == end else f"{month_label(start)} – {month_label(end)}"
    category_count = len(category_filter) if category_filter else len(categories)
    st.caption(f"{period}  •  {category_count} of {len(categories)} categories  •  "
               f"{len(channels)} sales channels  •  {len(regions)} customer regions  •  PHP")

    order_month = orders.order_datetime.dt.to_period("M").astype(str)
    selected = orders.loc[order_month.between(start, end)
                          & orders.sales_channel.isin(channels)
                          & orders.region_name.isin(regions)]
    selected_lines = fact.loc[fact.order_id.isin(selected.order_id)]
    if category_filter:
        selected_lines = selected_lines.loc[selected_lines.category.isin(category_filter)]
        selected = selected.loc[selected.order_id.isin(selected_lines.order_id)]
        st.caption("Sales and order values use the selected categories’ line items. "
                   "Order status and cancellation metrics count orders containing those categories.")
    if selected.empty:
        st.info("No orders match these filters. Adjust your selection or choose Reset filters.")
        return
    metrics = analyze(selected_lines, selected, start, end)
    kpis = [
        ("Merchandise Revenue", f"₱{metrics['revenue']:,.2f}", "Estimated sales from priced Completed and Shipped order lines."),
        ("Revenue-Bearing Orders", f"{metrics['order_count']:,}", "Distinct orders with at least one line contributing to revenue."),
        ("Average Order Value", f"₱{metrics['aov']:,.2f}" if metrics["order_count"] else "—", "Merchandise revenue divided by revenue-bearing orders."),
        ("Order Cancellation Rate", f"{selected.order_status.eq('Cancelled').mean():.1%}", "Cancelled orders as a share of all orders in the selection."),
    ]
    with st.container(key="scorecard"):
        for col, (label, value, help_text) in zip(st.columns(4), kpis):
            with col, st.container(border=True):
                st.metric(label, value, help=help_text)
    st.caption("Hover over a chart to see exact values.")

    sales, products, geography, customers, operations = st.tabs(
        ["Sales Overview", "Product Performance", "Customer Geography", "Customer Mix", "Order Operations"]
    )
    with sales:
        trend, channel = st.columns([2, 1])
        with trend:
            chart_card(metrics, "monthly")
        with channel:
            chart_card(metrics, "channels")
        chart_card(metrics, "order_values")
    with products:
        top, breakdown = st.columns([1.2, 1])
        with top:
            chart_card(metrics, "products")
        with breakdown:
            chart_card(metrics, "categories")
    with geography:
        region, city = st.columns(2)
        with region:
            chart_card(metrics, "regions")
        with city:
            chart_card(metrics, "cities")
    with customers:
        left, right = st.columns(2)
        with left:
            chart_card(metrics, "customer_types")
        with right, st.container(border=True):
            st.markdown("#### Orders and Revenue by Customer Type")
            order_mix = metrics["order_mix"].rename_axis("Customer type").reset_index()
            st.dataframe(order_mix, hide_index=True, column_config={
                "revenue": st.column_config.NumberColumn("Revenue (PHP)", format="accounting"),
                "orders": st.column_config.NumberColumn("Orders", format="localized"),
            })
            st.markdown("#### Distinct Matched Customers")
            st.caption("Customers with any repeat order in this selection are counted as Repeat.")
            st.dataframe(metrics["customer_counts"].rename("Customers").rename_axis("Customer type").reset_index(),
                         hide_index=True)
    with operations:
        chart_card(metrics, "cancellation_rate")
        chart_card(metrics, "statuses")

    with st.expander("Metric Definitions and Data Quality"):
        st.markdown(
            "- Estimated merchandise revenue uses quantity × purchase price × (1 − order discount), rounded per line. "
            "A missing purchase price uses catalog price when available. A missing discount is treated as zero.\n"
            "- Revenue uses Completed and Shipped orders and excludes shipping fees and separately recorded refunds.\n"
            "- Average order value uses orders with at least one priced line. An order with an unpriced line can contribute a partial value.\n"
            "- Customer type uses full order history. When a category is selected, order value includes only matching lines.\n"
            "- Unknown groups include unmatched records where applicable. Product rankings use matched catalog products."
        )


if __name__ == "__main__":
    main()
