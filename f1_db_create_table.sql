use grandprix_hub;

USE grandprix_hub;

CREATE TABLE country (
    country_code VARCHAR(3) PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    continent VARCHAR(100) NOT NULL
);

CREATE TABLE constructor (
    constructor_id VARCHAR(100) PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    country_id VARCHAR(3) NOT NULL,
    year_from INTEGER NOT NULL,
    year_to INTEGER,
    previous_next_constructor_id VARCHAR(100),
    FOREIGN KEY (country_id) REFERENCES country(country_code),
    FOREIGN KEY (previous_next_constructor_id) REFERENCES constructor(constructor_id)
);

CREATE TABLE circuit (
    circuit_id VARCHAR(100) PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    type VARCHAR(6) NOT NULL,
    place_name VARCHAR(100) NOT NULL,
    country_id VARCHAR(3) NOT NULL,
    latitude DECIMAL(10, 6) NOT NULL,
    longitude DECIMAL(10, 6) NOT NULL,
    FOREIGN KEY (country_id) REFERENCES country(country_code)
);

CREATE TABLE driver (
    driver_id VARCHAR(100) PRIMARY KEY,
    abbreviation VARCHAR(3) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    permanent_number VARCHAR(2),
    gender VARCHAR(6) NOT NULL,
    date_of_birth DATE NOT NULL,
    date_of_death DATE,
    place_of_birth VARCHAR(100) NOT NULL,
    country_of_birth_id VARCHAR(3) NOT NULL,
    nationality_country_id VARCHAR(3) NOT NULL,
    FOREIGN KEY (country_of_birth_id) REFERENCES country(country_code),
    FOREIGN KEY (nationality_country_id) REFERENCES country(country_code)
);

CREATE TABLE season (
    year INTEGER PRIMARY KEY
);

CREATE TABLE race (
    season INTEGER NOT NULL,
    round INTEGER NOT NULL,
    date DATE NOT NULL,
    official_name VARCHAR(100) NOT NULL,
    qualifying_format VARCHAR(20) NOT NULL,
    circuit_id VARCHAR(100) NOT NULL,
    course_length DECIMAL(6,3) NOT NULL,
    laps INTEGER NOT NULL,
    distance DECIMAL(6,3) NOT NULL,
    PRIMARY KEY (season, round),
    FOREIGN KEY (season) REFERENCES season(year),
    FOREIGN KEY (circuit_id) REFERENCES circuit(circuit_id)
);

CREATE TABLE season_constructor_driver (
    season INTEGER NOT NULL,
    constructor_id VARCHAR(100) NOT NULL,
    driver_id VARCHAR(100) NOT NULL,
    rounds VARCHAR(100),
    test_driver BOOLEAN NOT NULL,
    PRIMARY KEY (season, constructor_id, driver_id),
    FOREIGN KEY (season) REFERENCES season(year),
    FOREIGN KEY (constructor_id) REFERENCES constructor(constructor_id),
    FOREIGN KEY (driver_id) REFERENCES driver(driver_id)
);

CREATE TABLE driver_of_the_day_results (
    season INTEGER NOT NULL,
    round INTEGER NOT NULL,
    position INTEGER NOT NULL,
    driver_id VARCHAR(100) NOT NULL,
    constructor_id VARCHAR(100) NOT NULL,
    percentage DECIMAL(4,1) NOT NULL,
    PRIMARY KEY (season, round, position),
    FOREIGN KEY (season, round) REFERENCES race(season, round),
    FOREIGN KEY (driver_id) REFERENCES driver(driver_id),
    FOREIGN KEY (constructor_id) REFERENCES constructor(constructor_id)
);

CREATE TABLE free_practice_results (
    number INTEGER NOT NULL,
    season INTEGER NOT NULL,
    round INTEGER NOT NULL,
    position INTEGER NOT NULL,
    driver_id VARCHAR(100) NOT NULL,
    constructor_id VARCHAR(100) NOT NULL,
    time VARCHAR(8),
    laps INTEGER,
    PRIMARY KEY (season, round, number, position),
    FOREIGN KEY (season, round) REFERENCES race(season, round),
    FOREIGN KEY (driver_id) REFERENCES driver(driver_id),
    FOREIGN KEY (constructor_id) REFERENCES constructor(constructor_id)
);

CREATE TABLE race_results (
    season INTEGER NOT NULL,
    round INTEGER NOT NULL,
    position INTEGER NOT NULL,
    driver_id VARCHAR(100) NOT NULL,
    constructor_id VARCHAR(100) NOT NULL,
    laps INTEGER,
    time VARCHAR(12),
    time_penalty VARCHAR(6),
    reason_retired VARCHAR(100),
    points INTEGER NOT NULL,
    grid_position INTEGER NOT NULL,
    PRIMARY KEY (season, round, position),
    FOREIGN KEY (season, round) REFERENCES race(season, round),
    FOREIGN KEY (driver_id) REFERENCES driver(driver_id),
    FOREIGN KEY (constructor_id) REFERENCES constructor(constructor_id)
);

CREATE TABLE quali_results (
    season INTEGER NOT NULL,
    round INTEGER NOT NULL,
    position INTEGER NOT NULL,
    driver_id VARCHAR(100) NOT NULL,
    constructor_id VARCHAR(100) NOT NULL,
    q1 VARCHAR(8),
    q2 VARCHAR(8),
    q3 VARCHAR(8),
    laps INTEGER NOT NULL,
    PRIMARY KEY (season, round, position),
    FOREIGN KEY (season, round) REFERENCES race(season, round),
    FOREIGN KEY (driver_id) REFERENCES driver(driver_id),
    FOREIGN KEY (constructor_id) REFERENCES constructor(constructor_id)
);

CREATE TABLE pit_stops (
    season INTEGER NOT NULL,
    round INTEGER NOT NULL,
    position INTEGER NOT NULL,
    driver_id VARCHAR(100) NOT NULL,
    constructor_id VARCHAR(100) NOT NULL,
    stop INTEGER NOT NULL,
    lap INTEGER NOT NULL,
    time VARCHAR(8) NOT NULL,
    PRIMARY KEY (season, round, position),
    FOREIGN KEY (season, round) REFERENCES race(season, round),
    FOREIGN KEY (driver_id) REFERENCES driver(driver_id),
    FOREIGN KEY (constructor_id) REFERENCES constructor(constructor_id)
);

CREATE TABLE sprint_quali_results (
    season INTEGER NOT NULL,
    round INTEGER NOT NULL,
    position INTEGER NOT NULL,
    driver_id VARCHAR(100) NOT NULL,
    constructor_id VARCHAR(100) NOT NULL,
    q1 VARCHAR(8),
    q2 VARCHAR(8),
    q3 VARCHAR(8),
    laps INTEGER NOT NULL,
    PRIMARY KEY (season, round, position),
    FOREIGN KEY (season, round) REFERENCES race(season, round),
    FOREIGN KEY (driver_id) REFERENCES driver(driver_id),
    FOREIGN KEY (constructor_id) REFERENCES constructor(constructor_id)
);

CREATE TABLE sprint_race_results (
    season INTEGER NOT NULL,
    round INTEGER NOT NULL,
    position INTEGER NOT NULL,
    driver_id VARCHAR(100) NOT NULL,
    constructor_id VARCHAR(100) NOT NULL,
    laps INTEGER,
    time VARCHAR(12),
    time_penalty VARCHAR(6),
    reason_retired VARCHAR(100),
    points INTEGER NOT NULL,
    grid_position INTEGER NOT NULL,
    PRIMARY KEY (season, round, position),
    FOREIGN KEY (season, round) REFERENCES race(season, round),
    FOREIGN KEY (driver_id) REFERENCES driver(driver_id),
    FOREIGN KEY (constructor_id) REFERENCES constructor(constructor_id)
);

CREATE TABLE user_credentials (
    username VARCHAR(100) PRIMARY KEY,
    password VARCHAR(100) NOT NULL,
    role ENUM('user', 'admin') NOT NULL
);

CREATE USER 'grandprix_hub_admin'@'localhost' IDENTIFIED BY 'grandprix_hub_admin_password';

GRANT ALL PRIVILEGES ON grandprix_hub.* TO 'grandprix_hub_admin'@'localhost';

CREATE USER 'grandprix_hub_maintainer'@'localhost' IDENTIFIED BY 'grandprix_hub_maintainer_password';

GRANT SELECT, INSERT, UPDATE, DELETE ON grandprix_hub.country TO 'grandprix_hub_maintainer'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON grandprix_hub.constructor TO 'grandprix_hub_maintainer'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON grandprix_hub.circuit TO 'grandprix_hub_maintainer'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON grandprix_hub.driver TO 'grandprix_hub_maintainer'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON grandprix_hub.season TO 'grandprix_hub_maintainer'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON grandprix_hub.race TO 'grandprix_hub_maintainer'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON grandprix_hub.season_constructor_driver TO 'grandprix_hub_maintainer'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON grandprix_hub.driver_of_the_day_results TO 'grandprix_hub_maintainer'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON grandprix_hub.free_practice_results TO 'grandprix_hub_maintainer'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON grandprix_hub.race_results TO 'grandprix_hub_maintainer'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON grandprix_hub.quali_results TO 'grandprix_hub_maintainer'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON grandprix_hub.sprint_quali_results TO 'grandprix_hub_maintainer'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON grandprix_hub.sprint_race_results TO 'grandprix_hub_maintainer'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON grandprix_hub.pit_stops TO 'grandprix_hub_maintainer'@'localhost';

CREATE USER 'grandprix_hub_user'@'localhost' IDENTIFIED BY 'grandprix_hub_user_password';

GRANT SELECT ON grandprix_hub.country TO 'grandprix_hub_user'@'localhost';
GRANT SELECT ON grandprix_hub.constructor TO 'grandprix_hub_user'@'localhost';
GRANT SELECT ON grandprix_hub.circuit TO 'grandprix_hub_user'@'localhost';
GRANT SELECT ON grandprix_hub.driver TO 'grandprix_hub_user'@'localhost';
GRANT SELECT ON grandprix_hub.season TO 'grandprix_hub_user'@'localhost';
GRANT SELECT ON grandprix_hub.race TO 'grandprix_hub_user'@'localhost';
GRANT SELECT ON grandprix_hub.season_constructor_driver TO 'grandprix_hub_user'@'localhost';
GRANT SELECT ON grandprix_hub.driver_of_the_day_results TO 'grandprix_hub_user'@'localhost';
GRANT SELECT ON grandprix_hub.free_practice_results TO 'grandprix_hub_user'@'localhost';
GRANT SELECT ON grandprix_hub.race_results TO 'grandprix_hub_user'@'localhost';
GRANT SELECT ON grandprix_hub.quali_results TO 'grandprix_hub_user'@'localhost';
GRANT SELECT ON grandprix_hub.sprint_quali_results TO 'grandprix_hub_user'@'localhost';
GRANT SELECT ON grandprix_hub.sprint_race_results TO 'grandprix_hub_user'@'localhost';
GRANT SELECT ON grandprix_hub.pit_stops TO 'grandprix_hub_user'@'localhost';
