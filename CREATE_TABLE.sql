CREATE TABLE transport_modes (
    mode_month_id serial PRIMARY KEY
    ,transport_month date
    ,Bus INT
    ,Ferry INT
    ,Light_Rail INT
    ,Metro INT
    ,Train INT
    ,Grand_Total INT
);

