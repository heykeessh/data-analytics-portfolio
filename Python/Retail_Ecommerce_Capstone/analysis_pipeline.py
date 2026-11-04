"""Clean the seven source tables and build reusable retail metrics."""
from pathlib import Path

import matplotlib.pyplot as plt
from matplotlib.ticker import FuncFormatter
import pandas as pd

ROOT = Path(__file__).resolve().parent
TABLES = {
    "customers": (["signup_date"], ["age"]),
    "products": (["launch_date"], ["unit_cost", "unit_price", "stock_qty"]),
    "orders": (["order_datetime"], ["discount_pct", "shipping_fee"]),
    "order_items": ([], ["quantity", "unit_price_at_purchase"]),
    "shipments": (["ship_date", "delivered_date"], []),
    "payments": (["payment_date"], ["amount_paid"]),
    "returns": (["return_request_date"], ["refund_amount"]),
}
CATEGORY_ALIASES = {
    "electronics": "Electronics", "elec": "Electronics",
    "beauty": "Beauty", "beauty & care": "Beauty",
    "books": "Books", "book": "Books",
    "toys": "Toys", "toy": "Toys",
    "fashion": "Fashion", "fashon": "Fashion",
    "groceries": "Groceries", "grocery": "Groceries",
    "home & kitchen": "Home & Kitchen", "home and kitchen": "Home & Kitchen",
    "sports": "Sports", "sports & outdoor": "Sports",
}
SALES_STATUSES = ["Completed", "Shipped"]


def clean_tables(source):
    tables, audit = {}, []
    for name, (dates, numbers) in TABLES.items():
        raw = pd.read_csv(source / f"{name}.csv", dtype="string")
        key = raw.columns[0]
        frame = raw.apply(lambda col: col.str.strip().replace("", pd.NA))
        frame = frame.drop_duplicates().copy()
        audit.append((name, "Exact duplicate rows removed", len(raw) - len(frame)))
        missing_keys = frame[key].isna()
        audit.append((name, "Missing primary keys removed", int(missing_keys.sum())))
        frame = frame.loc[~missing_keys].copy()
        if frame[key].duplicated().any():
            raise ValueError(f"Conflicting rows share a primary key in {name}")
        for col in dates + numbers:
            if col in dates:
                parsed = pd.to_datetime(frame[col], format="mixed", errors="coerce")
            else:
                parsed = pd.to_numeric(frame[col].str.replace(r"[₱,]", "", regex=True), errors="coerce")
            audit.append((name, f"Invalid nonblank {col}", int((parsed.isna() & frame[col].notna()).sum())))
            frame[col] = parsed
        tables[name] = frame

    products = tables["products"]
    category = products["category"].str.casefold()
    products["category"] = category.map(CATEGORY_ALIASES).fillna(products["category"]).fillna("Unknown")
    products["uom"] = products["uom"].replace({"pc": "piece", "pcs": "piece"})
    customers = tables["customers"]
    for col in ["gender", "loyalty_tier", "region_name", "city"]:
        customers[col] = customers[col].fillna("Unknown")
    returns = tables["returns"]
    returns["refunded_flag"] = returns["refunded_flag"].fillna("Unknown")
    no_refund = returns["refunded_flag"].eq("No") & returns["refund_amount"].isna()
    returns.loc[no_refund, "refund_amount"] = 0
    audit.append(("returns", "Blank refund amounts set to zero for explicit No", int(no_refund.sum())))

    orders = tables["orders"]
    discount_invalid = ~orders["discount_pct"].between(0, 1).fillna(False)
    orders["discount_assumed_zero"] = discount_invalid
    orders.loc[discount_invalid, "discount_pct"] = 0
    audit.append(("orders", "Missing or invalid discounts assumed zero", int(discount_invalid.sum())))

    links = [
        ("orders", "customer_id", "customers"),
        ("order_items", "order_id", "orders"),
        ("order_items", "product_id", "products"),
        ("shipments", "order_id", "orders"),
        ("payments", "order_id", "orders"),
        ("returns", "order_id", "orders"),
    ]
    for child, key, parent in links:
        frame = tables[child]
        unmatched = ~frame[key].isin(tables[parent][key])
        frame[f"{key}_matched"] = ~unmatched
        audit.append((child, f"Unmatched {key} retained and flagged", int(unmatched.sum())))

    items = tables["order_items"]
    list_price = items["product_id"].map(products.set_index("product_id")["unit_price"])
    observed = items["unit_price_at_purchase"].where(items["unit_price_at_purchase"].ge(0))
    items["analysis_unit_price"] = observed.fillna(list_price.where(list_price.ge(0)))
    items["price_source"] = "Missing"
    items.loc[observed.notna(), "price_source"] = "Purchase price"
    items.loc[observed.isna() & items["analysis_unit_price"].notna(), "price_source"] = "Catalog estimate"
    for label in ["Catalog estimate", "Missing"]:
        audit.append(("order_items", f"Price source · {label}", int(items["price_source"].eq(label).sum())))
    nonpositive = ~items["quantity"].gt(0).fillna(False)
    items["valid_quantity"] = ~nonpositive
    audit.append(("order_items", "Nonpositive or missing quantities retained and flagged", int(nonpositive.sum())))
    for name, frame in tables.items():
        for col, count in frame.isna().sum().items():
            if count:
                audit.append((name, f"Blanks retained in {col}", int(count)))
    return tables, pd.DataFrame(audit, columns=["table", "check", "rows"])


def build_fact(tables):
    orders = tables["orders"].copy()
    eligible = orders["order_status"].isin(SALES_STATUSES) & orders["order_datetime"].notna()
    known = orders.loc[eligible & orders["customer_id_matched"]].sort_values(["order_datetime", "order_id"])
    repeat = known.duplicated("customer_id")
    orders["customer_type"] = "Unknown"
    orders.loc[known.index[~repeat], "customer_type"] = "New"
    orders.loc[known.index[repeat], "customer_type"] = "Repeat"
    products = tables["products"][["product_id", "product_name", "category"]]
    customers = tables["customers"][["customer_id", "region_name", "city"]]
    fact = (tables["order_items"]
            .merge(orders, on="order_id", how="left", validate="many_to_one")
            .merge(products, on="product_id", how="left", validate="many_to_one")
            .merge(customers, on="customer_id", how="left", validate="many_to_one"))
    for col in ["region_name", "city", "category"]:
        fact[col] = fact[col].fillna("Unknown")
    fact["product_label"] = fact["product_name"].fillna("Unknown product") + " (" + fact["product_id"].fillna("no ID") + ")"
    valid = (fact["order_status"].isin(SALES_STATUSES) & fact["order_datetime"].notna()
             & fact["valid_quantity"] & fact["analysis_unit_price"].notna())
    fact["line_revenue"] = (
        fact["quantity"] * fact["analysis_unit_price"] * (1 - fact["discount_pct"])
    ).where(valid).round(2)
    assert len(fact) == len(tables["order_items"]) and fact["order_item_id"].is_unique
    return fact, orders


def analyze(fact, orders, start, end):
    months = pd.period_range(start, end, freq="M").astype(str)
    sales = fact.loc[fact["line_revenue"].notna()].copy()
    sales["month"] = sales["order_datetime"].dt.to_period("M").astype(str)
    orders = orders.copy()
    orders["month"] = orders["order_datetime"].dt.to_period("M").astype(str)
    orders["cancelled"] = orders["order_status"].eq("Cancelled")
    monthly_orders = orders.groupby("month").size().reindex(months, fill_value=0)
    cancelled = orders.groupby("month")["cancelled"].sum().reindex(months, fill_value=0)
    order_values = sales.groupby("order_id")["line_revenue"].sum()
    def revenue_by(col):
        return sales.groupby(col)["line_revenue"].sum().sort_values(ascending=False)
    known_customers = orders.loc[orders["customer_type"].isin(["New", "Repeat"])]
    customer_history = known_customers.groupby("customer_id")["customer_type"].agg(
        lambda types: "Repeat" if types.eq("Repeat").any() else "New"
    )
    order_mix = sales.groupby("customer_type").agg(
        revenue=("line_revenue", "sum"), orders=("order_id", "nunique")
    ).sort_values("revenue", ascending=False)
    top_products = (sales.loc[sales["product_id_matched"]]
                    .assign(product_name=lambda rows: rows["product_name"].fillna("Unknown product"))
                    .groupby(["product_id", "product_name"])["line_revenue"]
                    .sum().nlargest(10).droplevel("product_id"))
    return {
        "order_mix": order_mix,
        "customer_counts": customer_history.value_counts().reindex(["New", "Repeat"], fill_value=0),
        "sales": sales,
        "revenue": order_values.sum(),
        "order_count": len(order_values),
        "aov": order_values.mean(),
        "order_values": order_values,
        "monthly": sales.groupby("month")["line_revenue"].sum().reindex(months, fill_value=0),
        "products": top_products,
        "categories": revenue_by("category"),
        "regions": revenue_by("region_name"),
        "cities": revenue_by("city"),
        "channels": revenue_by("sales_channel"),
        "customer_types": revenue_by("customer_type"),
        "cancellation_rate": cancelled.div(monthly_orders.where(monthly_orders.gt(0))).mul(100),
        "statuses": orders["order_status"].value_counts(),
    }


CHARTS = [
    ("monthly", "Merchandise Revenue by Month", "line", "Order Month", "Merchandise Revenue (PHP)"),
    ("products", "Top 10 Products by Merchandise Revenue", "bar", "Merchandise Revenue (PHP)", "Product"),
    ("categories", "Merchandise Revenue by Product Category", "bar", "Merchandise Revenue (PHP)", "Product Category"),
    ("regions", "Merchandise Revenue by Customer Region", "bar", "Merchandise Revenue (PHP)", "Customer Region"),
    ("cities", "Top 10 Customer Cities by Merchandise Revenue", "bar", "Merchandise Revenue (PHP)", "Customer City"),
    ("order_values", "Distribution of Order Values", "hist", "Revenue per Order (PHP)", "Number of Orders"),
    ("cancellation_rate", "Order Cancellation Rate by Month", "line", "Order Month", "Cancellation Rate (%)"),
    ("channels", "Merchandise Revenue by Sales Channel", "bar", "Merchandise Revenue (PHP)", "Sales Channel"),
    ("customer_types", "Merchandise Revenue by Customer Type", "bar", "Merchandise Revenue (PHP)", "Customer Type"),
    ("statuses", "Order Volume by Status", "bar", "Number of Orders", "Order Status"),
]

def make_chart(metrics, spec):
    key, title, kind, xlabel, ylabel = spec
    values = metrics[key].head(10) if key == "cities" else metrics[key]
    fig, ax = plt.subplots(figsize=(9.8, 4.9), layout="constrained")
    fig.patch.set_facecolor("#f4f8ff")
    ax.set_facecolor("#f4f8ff")
    ax.set_title(title, loc="left", fontsize=17, fontweight="bold", color="#142c52", pad=16)
    for spine in ax.spines.values():
        spine.set_visible(False)
    ax.tick_params(length=0, labelcolor="#34536a", pad=6)
    ax.set_xlabel(xlabel, color="#142c52", fontweight="medium")
    ax.set_ylabel(ylabel, color="#142c52", fontweight="medium")
    ax.set_axisbelow(True)
    formatter = FuncFormatter(lambda value, _: f"{value/1e6:g}M" if abs(value) >= 1e6 else
                              f"{value/1e3:g}k" if abs(value) >= 1e3 else f"{value:g}")
    if values.dropna().empty:
        ax.text(.5, .5, "No data for this selection", ha="center", va="center", transform=ax.transAxes)
        ax.set_xticks([])
        ax.set_yticks([])
    elif kind == "line":
        ax.plot(values.index, values.to_numpy(dtype=float), color="#2563eb", linewidth=2.5, marker="o", markersize=4)
        step = max(1, (len(values) + 7) // 8)
        ticks = sorted(set(range(0, len(values), step)) | {len(values) - 1})
        labels = pd.PeriodIndex(values.index, freq="M").strftime("%b %Y")
        ax.set_xticks(ticks, [labels[i] for i in ticks], rotation=30, ha="right")
        ax.set_ylim(bottom=0)
        ax.yaxis.set_major_formatter(
            FuncFormatter(lambda value, _: f"{value:g}%") if key == "cancellation_rate" else formatter
        )
        ax.grid(axis="y", color="#dce8fa")
    elif kind == "hist":
        ax.hist(values, bins=28, color="#2563eb", edgecolor="#f4f8ff")
        ax.xaxis.set_major_formatter(formatter)
        ax.grid(axis="y", color="#dce8fa")
    else:
        positions = range(len(values))
        ax.barh(positions, values.iloc[::-1], color="#2563eb")
        ax.set_yticks(positions, values.index[::-1])
        ax.xaxis.set_major_formatter(formatter)
        ax.grid(axis="x", color="#dce8fa")
    return fig


def export_cleaned(tables, fact, folder):
    folder.mkdir(parents=True, exist_ok=True)
    for name, frame in tables.items():
        frame.to_csv(folder / f"{name}_clean.csv", index=False)
    fact.to_csv(folder / "sales_fact.csv", index=False, chunksize=2000)
