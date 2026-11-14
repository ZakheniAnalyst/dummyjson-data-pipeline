select
    user_id, first_name, last_name, username, email,
    age, gender, city, state, country, company_name
from {{ ref('stg_users') }}