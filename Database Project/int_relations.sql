BEGIN TRANSACTION;
DROP TABLE IF EXISTS country CASCADE;
CREATE TABLE IF NOT EXISTS country (
	name	text,
    year	numeric(4,0),
	code	varchar(3),
	gdp_growth_annual numeric,
    gdp_cap_growth numeric,
    health_exp_cap numeric,
    health_exp_gdp numeric,      
    gdp_cap_ppp numeric,         
    gdp_ppp numeric,            
    edu_exp numeric,             
    nat_resc_rent numeric,       
    women_seats numeric,        
    women_bus_law_score numeric, 
    life_exp numeric,            
    inf_mort numeric,           
    rd_exp numeric,              
    hi_tech_export numeric,      
    internet numeric,           
    ict_good_exp numeric,        
    ict_good_imp numeric,        
    ict_ser_exp numeric,        
    gini numeric,                
    ease_bus_score numeric,      
    milt_exp numeric,           
    total_score numeric,         
    pol_rights numeric,          
    civil_lib numeric,   
    PRIMARY KEY (name, year)
);

DROP TABLE IF EXISTS event CASCADE;
CREATE TABLE IF NOT EXISTS event (
	id	numeric,
    year	numeric(4,0),
	source_name text,
    source_sectors text,
    source_country text,
    source_country_code varchar(3),
    text text,
    cameo_code text,
    intensity numeric,
    target_name text,
    target_sectors text,
    target_country text,
    target_country_code varchar(3),
    city text,
    district text,
    province text,
    country text,
    latitude numeric,
    longitude numeric,
    PRIMARY KEY (id),
    foreign key (source_country, year) references country (name, year)
    	on delete cascade,
    foreign key (target_country, year) references country (name, year)
    	on delete cascade
);

DROP TABLE IF EXISTS dyad CASCADE;
CREATE TABLE IF NOT EXISTS dyad (
    source_country text,
    target_country text,
    year	numeric(4,0),
    affinity numeric,
    source_country_code varchar(3),
    target_country_code varchar(3),
    trade_balance_usd numeric,
    PRIMARY KEY (source_country, target_country, year),
    foreign key (source_country, year) references country (name, year)
    	on delete cascade,
    foreign key (target_country, year) references country (name, year)
    	on delete cascade
);

COMMIT;