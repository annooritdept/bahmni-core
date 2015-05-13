DELETE FROM global_property
WHERE property IN (
  'emrapi.sqlSearch.activePatients',
  'emrapi.sqlSearch.patientsToAdmit',
  'emrapi.sqlSearch.admittedPatients',
  'emrapi.sqlSearch.patientsToDischarge',
  'emrapi.sqlSearch.patientsHasPendingOrders',
  'emrapi.sqlSearch.highRiskPatients',
  'emrapi.sqlSearch.additionalSearchHandler'
);

INSERT INTO global_property (`property`, `property_value`, `description`, `uuid`)
VALUES ('emrapi.sqlSearch.activePatients',
        'select distinct concat(pn.given_name,\' \', pn.family_name) as name, pi.identifier as identifier, concat("",p.uuid) as uuid, concat("",v.uuid) as activeVisitUuid from visit v join person_name pn on v.patient_id = pn.person_id and pn.voided = 0 join patient_identifier pi on v.patient_id = pi.patient_id join person p on p.person_id = v.patient_id where v.date_stopped is null AND v.voided = 0',
        'Sql query to get list of active patients',
        uuid()
);

INSERT INTO global_property (`property`, `property_value`, `description`, `uuid`)
VALUES ('emrapi.sqlSearch.patientsToAdmit',
        'select distinct concat(pn.given_name,\' \', pn.family_name) as name, pi.identifier as identifier, concat("",p.uuid) as uuid, concat("",v.uuid) as activeVisitUuid from visit v join person_name pn on v.patient_id = pn.person_id and pn.voided = 0 AND v.voided = 0 join patient_identifier pi on v.patient_id = pi.patient_id join person p on v.patient_id = p.person_id join encounter e on v.visit_id = e.visit_id join obs o on e.encounter_id = o.encounter_id and o.voided = 0 join concept c on o.value_coded = c.concept_id join concept_name cn on c.concept_id = cn.concept_id where v.date_stopped is null and cn.name = \'Admit Patient\' and v.visit_id not in (select visit_id from encounter ie join encounter_type iet on iet.encounter_type_id = ie.encounter_type where iet.name = \'ADMISSION\')',
        'Sql query to get list of patients to be admitted',
        uuid()
);

INSERT INTO global_property (`property`, `property_value`, `description`, `uuid`)
VALUES ('emrapi.sqlSearch.patientsToDischarge',
        'SELECT DISTINCT concat(pn.given_name, \' \', pn.family_name) AS name,pi.identifier AS identifier, concat("", p.uuid) AS uuid, concat("", v.uuid) AS activeVisitUuid FROM visit v INNER JOIN person_name pn ON v.patient_id = pn.person_id and pn.voided is FALSE INNER JOIN patient_identifier pi ON v.patient_id = pi.patient_id and pi.voided is FALSE INNER JOIN person p ON v.patient_id = p.person_id Inner Join (SELECT DISTINCT v.visit_id FROM encounter en INNER JOIN visit v ON v.visit_id = en.visit_id AND en.encounter_type = (SELECT encounter_type_id FROM encounter_type WHERE name = \'ADMISSION\')) v1 on v1.visit_id = v.visit_id INNER JOIN encounter e ON v.visit_id = e.visit_id INNER JOIN obs o ON e.encounter_id = o.encounter_id INNER JOIN concept_name cn ON o.value_coded = cn.concept_id AND cn.concept_name_type = \'FULLY_SPECIFIED\' AND cn.voided is FALSE LEFT OUTER JOIN encounter e1 ON e1.visit_id = v.visit_id AND e1.encounter_type = (SELECT encounter_type_id FROM encounter_type WHERE name = \'DISCHARGE\') AND e1.voided is FALSE WHERE v.date_stopped IS NULL AND v.voided = 0 AND o.voided = 0 cn.name = \'Discharge Patient\' AND e1.encounter_id IS NULL',
        'Sql query to get list of patients to discharge',
        uuid()
);

INSERT INTO global_property (`property`, `property_value`, `description`, `uuid`)
VALUES ('emrapi.sqlSearch.patientsHasPendingOrders',
        'select distinct concat(pn.given_name, \' \', pn.family_name) as name, pi.identifier as identifier, concat("",p.uuid) as uuid, concat("",v.uuid) as activeVisitUuid from visit v join person_name pn on v.patient_id = pn.person_id and pn.voided = 0 join patient_identifier pi on v.patient_id = pi.patient_id join person p on p.person_id = v.patient_id join orders on orders.patient_id = v.patient_id join order_type on orders.order_type_id = order_type.order_type_id and order_type.name != \'Lab Order\' and order_type.name != \'Drug Order\' where v.date_stopped is null AND v.voided = 0 and order_id not in(select obs.order_id from obs where person_id = pn.person_id and order_id = orders.order_id)',
        'Sql query to get list of patients who has pending orders',
        uuid()
);

INSERT INTO global_property (`property`, `property_value`, `description`, `uuid`)
VALUES ('emrapi.sqlSearch.admittedPatients',
        'select distinct concat(pn.given_name,\' \', pn.family_name) as name, pi.identifier as identifier, concat("",p.uuid) as uuid, concat("",v.uuid) as activeVisitUuid from encounter e join visit v on e.visit_id = v.visit_id join person_name pn on v.patient_id = pn.person_id and pn.voided = 0 join patient_identifier pi on v.patient_id = pi.patient_id join person p on v.patient_id = p.person_id join encounter_type et on et.encounter_type_id = e.encounter_type where v.date_stopped is null AND v.voided = 0 and et.name = \'ADMISSION\' e.voided = FALSE AND and e.patient_id not in (select distinct enc.patient_id from encounter enc join encounter_type ent on enc.encounter_type = ent.encounter_type_id where ent.name = \'DISCHARGE\'  AND enc.voided = FALSE AND enc.patient_id = v.patient_id AND v.visit_id = enc.visit_id)',
        'Sql query to get list of admitted patients',
        uuid()
);

INSERT INTO global_property (`property`, `property_value`, `description`, `uuid`)
VALUES ('emrapi.sqlSearch.highRiskPatients',
        'select distinct concat(pn.given_name,\' \', pn.family_name) as name, pi.identifier as identifier, concat("",p.uuid) as uuid, concat("",v.uuid) as activeVisitUuid
          FROM obs o
          INNER JOIN concept_name cn ON o.concept_id = cn.concept_id AND cn.concept_name_type="FULLY_SPECIFIED"
          INNER JOIN person_name pn ON o.person_id = pn.person_id
          INNER JOIN visit v ON v.patient_id=pn.person_id AND v.date_stopped IS NULL
          INNER JOIN patient_identifier pi ON v.patient_id = pi.patient_id
          INNER JOIN person p ON v.patient_id = p.person_id
          LEFT OUTER JOIN concept_name cn2 on o.value_coded = cn2.concept_id and cn.concept_name_type="FULLY_SPECIFIED" WHERE',
        'Sql query to get list of admitted patients',
        uuid()
);

INSERT INTO global_property (`property`, `property_value`, `description`, `uuid`)
VALUES ('emrapi.sqlSearch.additionalSearchHandler',
        ' (cn.name = ${testName} AND (o.value_numeric=${value} OR o.value_text=${value} OR cn2.name=${value})) ',
        'Sql query to get list of admitted patients',
        uuid()
);