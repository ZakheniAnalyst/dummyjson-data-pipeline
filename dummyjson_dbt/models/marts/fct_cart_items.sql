select
    ci.cart_id,
    c.user_id,
    ci.product_id,
    p.title        as product_title,
    p.category,
    p.brand,
    ci.quantity,
    ci.unit_price,
    ci.line_total,
    ci.line_discounted_total
from {{ ref('stg_cart_items') }} ci
join {{ ref('stg_carts') }} c on c.cart_id = ci.cart_id
left join {{ ref('stg_products') }} p on p.product_id = ci.product_id