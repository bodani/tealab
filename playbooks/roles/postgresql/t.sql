 ------------------------------------------备份--------------------------------------------------------------------
 psql -U postgres -d normandy_cloud_tsdb  -p 5432 -h 127.0.0.1 -c "\copy (SELECT * FROM public.pda_message WHERE message_ptr_id in (SELECT message_id FROM public.message_message WHERE created_time < '2023-01-01')) to '/tmp/pda_message.csv'";

 psql -U postgres -d normandy_cloud_tsdb  -p 5432 -h 127.0.0.1 -c "\copy (SELECT * FROM public.message_message WHERE created_time < '2021-01-01') to '/tmp/message_message_befor2021.csv'";

 psql -U postgres -d normandy_cloud_tsdb  -p 5432 -h 127.0.0.1 -c "\copy (SELECT * FROM public.message_message WHERE created_time >= '2021-01-01' and created_time < '2022-01-01' ) to '/tmp/message_message_2021.csv'";

 psql -U postgres -d normandy_cloud_tsdb  -p 5432 -h 127.0.0.1 -c "\copy (SELECT * FROM public.message_message WHERE created_time >= '2022-01-01' and created_time < '2023-01-01' ) to '/tmp/message_message_2022.csv'";

--------------------------------------------删除--------------------------------------------------------------------
DELETE FROM public.pda_message
    WHERE message_ptr_id in (SELECT message_id FROM public.message_message WHERE created_time < '2020-01-01'); 

DELETE FROM public.pda_message
    WHERE message_ptr_id in (SELECT message_id FROM public.message_message WHERE created_time >= '2020-01-01' and created_time < '2020-06-01'); 

DELETE FROM public.pda_message
    WHERE message_ptr_id in (SELECT message_id FROM public.message_message WHERE created_time >= '2020-06-01' and created_time < '2021-01-01'); 

DELETE FROM public.pda_message
    WHERE message_ptr_id in (SELECT message_id FROM public.message_message WHERE created_time >= '2021-01-01' and created_time < '2021-06-01'); 

DELETE FROM public.pda_message
    WHERE message_ptr_id in (SELECT message_id FROM public.message_message WHERE created_time >= '2021-06-01' and created_time < '2022-01-01'); 

DELETE FROM public.pda_message
    WHERE message_ptr_id in (SELECT message_id FROM public.message_message WHERE created_time >= '2022-01-01' and created_time < '2022-02-01'); 

DELETE FROM public.pda_message
    WHERE message_ptr_id in (SELECT message_id FROM public.message_message WHERE created_time >= '2022-02-01' and created_time < '2022-04-01'); 

DELETE FROM public.pda_message
    WHERE message_ptr_id in (SELECT message_id FROM public.message_message WHERE created_time >= '2022-04-01' and created_time < '2022-06-01'); 

DELETE FROM public.pda_message
    WHERE message_ptr_id in (SELECT message_id FROM public.message_message WHERE created_time >= '2022-06-01' and created_time < '2022-07-01'); 

DELETE FROM public.pda_message
    WHERE message_ptr_id in (SELECT message_id FROM public.message_message WHERE created_time >= '2022-07-01' and created_time < '2022-08-01'); 

DELETE FROM public.pda_message
    WHERE message_ptr_id in (SELECT message_id FROM public.message_message WHERE created_time >= '2022-08-01' and created_time < '2022-09-01'); 

DELETE FROM public.pda_message
    WHERE message_ptr_id in (SELECT message_id FROM public.message_message WHERE created_time >= '2022-09-01' and created_time < '2022-10-01'); 

DELETE FROM public.pda_message
    WHERE message_ptr_id in (SELECT message_id FROM public.message_message WHERE created_time >= '2022-10-01' and created_time < '2022-11-01'); 

DELETE FROM public.pda_message
    WHERE message_ptr_id in (SELECT message_id FROM public.message_message WHERE created_time >= '2022-10-01' and created_time < '2022-12-01'); 

DELETE FROM public.pda_message
    WHERE message_ptr_id in (SELECT message_id FROM public.message_message WHERE created_time >= '2022-12-01' and created_time < '2023-01-01'); 

---------------------------------------------删除------------------------------------------------------------------
DELETE FROM public.message_message WHERE created_time < '2020-01-01'; 
DELETE FROM public.message_message WHERE created_time < '2020-06-01';
DELETE FROM public.message_message WHERE created_time < '2021-01-01'; 
DELETE FROM public.message_message WHERE created_time < '2021-04-01';
DELETE FROM public.message_message WHERE created_time < '2021-08-01';
DELETE FROM public.message_message WHERE created_time < '2022-01-01'; 
DELETE FROM public.message_message WHERE created_time < '2022-02-01'; 
DELETE FROM public.message_message WHERE created_time < '2022-03-01'; 
DELETE FROM public.message_message WHERE created_time < '2022-04-01'; 
DELETE FROM public.message_message WHERE created_time < '2022-05-01'; 
DELETE FROM public.message_message WHERE created_time < '2022-06-01'; 
DELETE FROM public.message_message WHERE created_time < '2022-07-01'; 
DELETE FROM public.message_message WHERE created_time < '2022-08-01'; 
DELETE FROM public.message_message WHERE created_time < '2022-09-01'; 
DELETE FROM public.message_message WHERE created_time < '2022-10-01'; 
DELETE FROM public.message_message WHERE created_time < '2022-12-01'; 
DELETE FROM public.message_message WHERE created_time < '2022-12-01'; 
DELETE FROM public.message_message WHERE created_time < '2023-01-01'; 
DELETE FROM public.message_message where message_id in (SELECT message_id FROM public.message_message WHERE  created_time < '2022-06-01' limit 20000) ; 
DELETE FROM public.message_message where message_id in (SELECT message_id FROM public.message_message WHERE  created_time < '2023-01-01' limit 20000) ; 