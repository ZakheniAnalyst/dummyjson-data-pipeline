select
    v:id::int                       as user_id,
    v:firstName::string             as first_name,
    v:lastName::string              as last_name,
    v:username::string              as username,
    v:email::string                 as email,
    v:age::int                      as age,
    v:gender::string                as gender,
    v:address:city::string          as city,
    v:address:state::string         as state,
    v:address:country::string       as country,
    v:company:name::string          as company_name,
    v:role::string                  as role,
    _loaded_at
from {{ source('raw', 'raw_users') }}
qualify row_number() over (partition by v:id::int order by _loaded_at desc) = 1