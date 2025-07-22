
select * from  rfm_retail_mv;


--Manual refresh materialized view
begin
dbms_mview.refresh('rfm_retail_mv','c'); 
end;
/


