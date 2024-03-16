--Create Tables--

CREATE TABLE user_details (uid SERIAL PRIMARY KEY, name VARCHAR(30), password VARCHAR(30), address VARCHAR(50), mobile VARCHAR(10), email varchar(40));

CREATE TABLE user_role_management(rid SERIAL,uid INT ,admin_id INT, ROLE VARCHAR(10),FOREIGN KEY (UID) REFERENCES user_details (uid), FOREIGN KEY (admin_id) REFERENCES user_details (uid), primary key (rid, uid));

CREATE TABLE DEVICE (DEVICE_ID VARCHAR(20), LOGITUDE VARCHAR(20), LATITUDE VARCHAR(20), DESCRIPTION VARCHAR(50), PRIMARY KEY (device_id));

CREATE TABLE DEVICE_MANAGEMENT(UID INT, DEVICE_ID VARCHAR(20), ACCESS BOOLEAN, PRIMARY KEY(UID, DEVICE_ID), FOREIGN KEY (UID) REFERENCES user_details (uid), FOREIGN KEY (device_id) REFERENCES DEVICE (DEVICE_ID));


CREATE TABLE SENSOR_PARAMETERS(SLAVE_ID VARCHAR(10),DEVICE_ID VARCHAR(20), REG_ADD VARCHAR(10),KEYS VARCHAR(40), MINVALUE INT, MAXVALUE INT, SIUNIT VARCHAR(5), FOREIGN KEY (DEVICE_ID) REFERENCES DEVICE (DEVICE_ID), PRIMARY KEY (DEVICE_ID,REG_ADD,SLAVE_ID));

CREATE TABLE SENSOR_VALUE (DEVICE_ID VARCHAR(20),SLAVE_ID VARCHAR(10),REG_ADD VARCHAR(10),VALUE FLOAT, U_TIME TIMESTAMP,D_TTIME VARCHAR(25),PRIMARY KEY (DEVICE_ID, SLAVE_ID, REG_ADD, U_TIME),FOREIGN KEY (DEVICE_ID, REG_ADD, SLAVE_ID) REFERENCES SENSOR_PARAMETERS(DEVICE_ID, REG_ADD, SLAVE_ID));

CREATE TABLE todo (
  todo_id SERIAL PRIMARY KEY,
  user_name VARCHAR(30),
  description VARCHAR(255),
  completed BOOLEAN,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  end_date DATE
);

CREATE TABLE Weight_logging (
    DEVICE_ID VARCHAR(20),
    SLAVE_ID VARCHAR(10),
    REG_ADD VARCHAR(10),
    VALUE FLOAT,
    U_TIME TIMESTAMP,
    D_TIME VARCHAR(25),
    PRIMARY KEY (DEVICE_ID, SLAVE_ID, REG_ADD, U_TIME),
    FOREIGN KEY (DEVICE_ID, REG_ADD, SLAVE_ID) REFERENCES SENSOR_PARAMETERS(DEVICE_ID, REG_ADD, SLAVE_ID)
);

--Insert into user_details

Insert into user_details VALUES(001,'admin','admin123','RVCE','12345678','admin@gmail.com')

--Insert into Device 

INSERT INTO DEVICE VALUES ('1014', '190273', '029380', 'Location');
  

--Insert into SENSOR_PARAMETERS

INSERT INTO SENSOR_PARAMETERS values('3','1014','0','R',0,1000,'Volts');
INSERT INTO SENSOR_PARAMETERS values('3','1014','2','Y',0,1000,'Volts');
INSERT INTO SENSOR_PARAMETERS values('3','1014','4','B',0,1000,'Volts');
INSERT INTO SENSOR_PARAMETERS values('3','1014','56','Frequency',0,1000,'Hz');
INSERT INTO SENSOR_PARAMETERS values('2','1014','2','pH',0,1000,'Value');
INSERT INTO SENSOR_PARAMETERS values('2','1014','3','Temprature',0,1000,'°C');
INSERT INTO SENSOR_PARAMETERS values('7','1014','0','Weight',0,1000,'KG');

--Select query of DashBoard

 SELECT
    sv.device_id AS "device_id",
    MAX(CASE WHEN sp.reg_add = '0' AND sv.slave_id = '3' THEN sv.value END) AS "r",
    MAX(CASE WHEN sp.reg_add = '2' AND sv.slave_id = '3' THEN sv.value END) AS "y",
    MAX(CASE WHEN sp.reg_add = '4' AND sv.slave_id = '3' THEN sv.value END) AS "b",
    MAX(CASE WHEN sp.reg_add = '56' AND sv.slave_id = '3' THEN sv.value END) AS "frequency",
    MAX(CASE WHEN sp.reg_add = '2' AND sv.slave_id = '2' THEN sv.value END) AS "ph",
    MAX(CASE WHEN sp.reg_add = '3' AND sv.slave_id = '2' THEN sv.value END) AS "temperature",
    MAX(CASE WHEN sp.reg_add = '0' AND sv.slave_id = '7' THEN sv.value END) AS "weight",
    MAX(sv.d_time) AS "dtime"
    FROM
        sensor_value sv
    JOIN
        sensor_parameters sp ON sv.device_id = sp.device_id AND sv.slave_id = sp.slave_id AND sv.reg_add = sp.reg_add
    WHERE
        sv.device_id = '1014'
    GROUP BY
        sv.device_id, sv.d_time
    ORDER BY
        "dtime" DESC;

--Insert into Weight_Logging
Insert into weight_logging SELECT
  sv.device_id, sv.slave_id, sv.reg_add, sv.value, sv.u_time, sv.d_time
FROM sensor_value sv
WHERE sv.slave_id = '7'
ORDER BY sv.u_time DESC limit 1;



-- app.get("/api/v1/sensor_values/:deviceid", async (req, res) => {
--   try { 
--       const deviceId = req.params.deviceid;
--       const query = `
--       SELECT  
--           slave_id,
--           array_agg(reg_add ORDER BY reg_add) AS reg_addresses,
--           array_agg(keys ORDER BY reg_add) AS keys
--       FROM
--           sensor_parameters
--       WHERE
--           device_id = $1
--       GROUP BY
--           slave_id
--       `;
      
--      const result = await db.query(query, [deviceId]);
--       const sensorParamsQuery = await db.query(`
--           SELECT
--               sv.device_id AS "device_id",  
--               ${generateSelectClauses(result.rows)},
--               MAX(TO_TIMESTAMP(sv.d_time, 'DD/MM/YY HH24:MI:SS')) AS "dtime"
--           FROM
--               sensor_value sv
--           JOIN
--               sensor_parameters sp ON sv.device_id = sp.device_id AND sv.slave_id = sp.slave_id AND sv.reg_add = sp.reg_add
--           WHERE
--               sv.device_id = $1
--           GROUP BY
--               sv.device_id, sv.d_time
--           ORDER BY
--               "dtime" DESC;
--       `, [deviceId]);

--       res.status(200).json(sensorParamsQuery.rows);
--   } catch (err) {
--       console.error(err.message);
--       res.status(500).json({ error: "Internal Server Error" });
--   }
-- });