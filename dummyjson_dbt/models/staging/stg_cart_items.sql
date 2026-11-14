select
    c.v:id::int                     as cart_id,
    i.value:id::int                 as product_id,
    i.value:quantity::int           as quantity,
    i.value:price::float            as unit_price,
    i.value:total::float            as line_total,
    i.value:discountedTotal::float  as line_discounted_total
from {{ source('raw', 'raw_carts') }} c,
     lateral flatten(input => c.v:products) i
qualify row_number() over (
    partition by c.v:id::int, i.value:id::int order by c._loaded_at desc) = 1