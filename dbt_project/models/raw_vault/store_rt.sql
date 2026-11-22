{{ config(materialized='view') }}

{%- set yaml_metadata -%}
ref_hub: 'store_rh'
ref_satellites: 
    store_rs_v1:
        include:
            - store_name
            - is_active
historized: 'latest'
{%- endset -%}

{{ datavault4dbt.ref_table(yaml_metadata=yaml_metadata) }}