select
    v:id::int                       as product_id,
    v:title::string                 as title,
    v:category::string              as category,
    v:brand::string                 as brand,
    v:price::float                  as price,
    v:discountPercentage::float     as discount_pct,
    v:rating::float                 as rating,
    v:stock::int                    as stock,
    v:availabilityStatus::string    as availability_status,
    v:sku::string                   as sku,
    _loaded_at
from {{ source('raw', 'raw_products') }}
qualify row_number() over (partition by v:id::int order by _loaded_at desc) = 1