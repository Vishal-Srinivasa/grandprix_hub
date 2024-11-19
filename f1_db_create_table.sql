CREATE DATABASE grandprix_hub;

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
    test_driver enum('Yes', 'No') NOT NULL,
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
    password VARCHAR(100) NOT NULL
);

CREATE TABLE maintainer_credentials (
    username VARCHAR(100) PRIMARY KEY,
    password VARCHAR(100) NOT NULL
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


DELIMITER //
CREATE TRIGGER check_new_user
BEFORE INSERT ON user_credentials
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1 FROM user_credentials 
        WHERE username = NEW.username
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'User already exists, insertion not allowed.';
    END IF;
END //
DELIMITER ;


DELIMITER //
CREATE PROCEDURE get_constructor_standings(IN season_year INT)
BEGIN
  SELECT
    ROW_NUMBER() OVER (ORDER BY SUM(points) DESC) AS position,
    constructor_id,
    SUM(points) AS points
  FROM (
    SELECT season, constructor_id, points FROM sprint_race_results
    UNION ALL
    SELECT season, constructor_id, points FROM race_results
  ) AS all_results
  WHERE season = season_year
  GROUP BY constructor_id
  ORDER BY points DESC;
END //
DELIMITER ;


DELIMITER //
CREATE PROCEDURE get_driver_standings(IN season_year INT)
BEGIN
  SELECT 
    ROW_NUMBER() OVER (ORDER BY SUM(points) DESC) AS position,
    driver_id,
    constructor_id,
    SUM(points) AS points
  FROM (
    SELECT season, driver_id, constructor_id, points FROM sprint_race_results
    UNION ALL
    SELECT season, driver_id, constructor_id, points FROM race_results
  ) AS all_results
  WHERE season = season_year
  GROUP BY driver_id, constructor_id
  ORDER BY points DESC;
END //
DELIMITER ;

GRANT EXECUTE ON PROCEDURE grandprix_hub.get_driver_standings TO 'grandprix_hub_user'@'localhost';
GRANT EXECUTE ON PROCEDURE grandprix_hub.get_constructor_standings TO 'grandprix_hub_user'@'localhost';



DELIMITER //

CREATE FUNCTION get_race_wins(id VARCHAR(100))
RETURNS INTEGER
DETERMINISTIC
BEGIN
    DECLARE race_wins INTEGER;
    SELECT COUNT(*) INTO race_wins FROM race_results WHERE position = 1 AND driver_id = id;
    RETURN race_wins;
END //

CREATE FUNCTION get_pole_positions(id VARCHAR(100))
RETURNS INTEGER
DETERMINISTIC
BEGIN
    DECLARE pole_positions INTEGER;
    SELECT COUNT(*) INTO pole_positions FROM quali_results WHERE position = 1 AND driver_id = id;
    RETURN pole_positions;
END //

CREATE FUNCTION get_podiums(id VARCHAR(100))
RETURNS INTEGER
DETERMINISTIC
BEGIN
    DECLARE podiums INTEGER;
    SELECT COUNT(*) INTO podiums FROM race_results WHERE position <= 3 AND driver_id = id;
    RETURN podiums;
END //

CREATE FUNCTION get_sprint_wins(id VARCHAR(100))
RETURNS INTEGER
DETERMINISTIC
BEGIN
    DECLARE sprint_wins INTEGER;
    SELECT COUNT(*) INTO sprint_wins FROM sprint_race_results WHERE position = 1 AND driver_id = id;
    RETURN sprint_wins;
END //

DELIMITER ;


GRANT EXECUTE ON FUNCTION grandprix_hub.get_race_wins TO 'grandprix_hub_user'@'localhost';
GRANT EXECUTE ON FUNCTION grandprix_hub.get_pole_positions TO 'grandprix_hub_user'@'localhost';
GRANT EXECUTE ON FUNCTION grandprix_hub.get_podiums TO 'grandprix_hub_user'@'localhost';
GRANT EXECUTE ON FUNCTION grandprix_hub.get_sprint_wins TO 'grandprix_hub_user'@'localhost';



DELIMITER //

CREATE PROCEDURE get_driver_and_race_stats(IN p_driver_id VARCHAR(100), IN p_season INT, IN p_round INT)
BEGIN
  SELECT
    rr.position AS race_position,
    rr.constructor_id AS race_constructor_id,
    rr.laps AS race_laps,
    rr.time AS race_time,
    rr.time_penalty AS race_time_penalty,
    rr.reason_retired AS race_reason_retired,
    rr.points AS race_points,
    rr.grid_position AS race_grid_position,
    ps.position AS pit_stop_position,
    ps.stop AS pit_stop_number,
    ps.lap AS pit_stop_lap,
    ps.time AS pit_stop_time,
    qr.position AS quali_position,
    qr.q1 AS quali_q1,
    qr.q2 AS quali_q2,
    qr.q3 AS quali_q3,
    qr.laps AS quali_laps,
    srr.position AS sprint_race_position,
    srr.laps AS sprint_race_laps,
    srr.time AS sprint_race_time,
    srr.time_penalty AS sprint_race_time_penalty,
    srr.reason_retired AS sprint_race_reason_retired,
    srr.points AS sprint_race_points,
    srr.grid_position AS sprint_race_grid_position,
    sqr.position AS sprint_quali_position,
    sqr.q1 AS sprint_quali_q1,
    sqr.q2 AS sprint_quali_q2,
    sqr.q3 AS sprint_quali_q3,
    sqr.laps AS sprint_quali_laps,
    ddr.position AS driver_of_day_position,
    ddr.percentage AS driver_of_day_percentage
  FROM race_results rr
  LEFT JOIN driver_of_the_day_results ddr
    ON ddr.season = rr.season AND ddr.round = rr.round AND ddr.driver_id = rr.driver_id
  LEFT JOIN quali_results qr
    ON rr.season = qr.season AND rr.round = qr.round AND rr.driver_id = qr.driver_id
  LEFT JOIN pit_stops ps
    ON rr.season = ps.season AND rr.round = ps.round AND rr.driver_id = ps.driver_id
  LEFT JOIN sprint_quali_results sqr
    ON rr.season = sqr.season AND rr.round = sqr.round AND rr.driver_id = sqr.driver_id
  LEFT JOIN sprint_race_results srr
    ON rr.season = srr.season AND rr.round = srr.round AND rr.driver_id = srr.driver_id
  WHERE rr.driver_id = p_driver_id
    AND rr.round = p_round AND rr.season = p_season;
END //

DELIMITER ;

GRANT EXECUTE ON PROCEDURE grandprix_hub.get_driver_and_race_stats TO 'grandprix_hub_user'@'localhost';



DELIMITER //

CREATE TRIGGER check_sprint_fp_sessions
BEFORE INSERT ON free_practice_results
FOR EACH ROW
BEGIN
  DECLARE is_sprint_weekend BOOLEAN;
  
  SELECT EXISTS (
    SELECT 1 FROM sprint_race_results 
    WHERE season = NEW.season AND round = NEW.round
  ) INTO is_sprint_weekend;
  
  IF EXISTS (
    SELECT 1 FROM free_practice_results 
    WHERE season = NEW.season 
    AND round = NEW.round 
    AND number IN (2, 3)
    AND number != NEW.number
  ) THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Sprint weekends cannot have FP2 or FP3 sessions';
  END IF;
END //

DELIMITER ;