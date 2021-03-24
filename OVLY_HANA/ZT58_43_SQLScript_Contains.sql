select 
"CLIENT",
"NODE_KEY",
"EMPLOYEE_ID",
"FIRST_NAME",
"MIDDLE_NAME",
"LAST_NAME"
 from "SAPHANADB"."SNWD_EMPLOYEES"
 where contains( 
 	( "FIRST_NAME", "MIDDLE_NAME", "LAST_NAME" ),
 	'Hicks',
 	fuzzy( 1 )
 	)
