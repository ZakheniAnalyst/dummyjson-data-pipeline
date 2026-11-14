select
    p.v:id::int                     as product_id,
    r.index                         as review_idx,
    r.value:rating::int             as rating,
    r.value:comment::string         as comment,
    r.value:reviewerName::string    as reviewer_name,
    r.value:date::timestamp_ntz     as reviewed_at
from {{ source('raw', 'raw_products') }} p,
     lateral flatten(input => p.v:reviews) r
qualify row_number() over (
    partition by p.v:id::int, r.index order by p._loaded_at desc) = 1