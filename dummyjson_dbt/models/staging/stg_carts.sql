select
    v:id::int                       as cart_id,
    v:userId::int                   as user_id,
    v:total::float                  as total,
    v:discountedTotal::float        as discounted_total,
    v:totalProducts::int            as total_products,
    v:totalQuantity::int            as total_quantity,
    _loaded_at
from {{ source('raw', 'raw_carts') }}
qualify row_number() over (partition by v:id::int order by _loaded_at desc) = 1