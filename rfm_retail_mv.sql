Create materialized view rfm_retail_mv
build immediate
refresh complete
start with sysdate
next sysdate + 7 
as

with retail_rfm as(

select
customerid,
round(sysdate - max(invoicedate)) as recency,
count(distinct invoiceno) as frequency,
round(sum(quantity * unitprice), 2) as monetary
from retail
where customerid is not null group by customerid),

rfm_scores as(

select
customerid,recency,
frequency,monetary,
ntile(5) over (order by recency asc) as r_score,
ntile(5) over (order by frequency desc) as f_score,
ntile(5) over (order by monetary desc) as m_score
from retail_rfm ) 

select
customerid,recency,
frequency,monetary,
r_score,f_score,m_score,
(r_score + f_score + m_score) as rfm_total_score,

case 
when r_score = 5 and f_score between 4 and 5 and m_score between 4 and 5 then 'champions'
when r_score between 3 and 4 and f_score between 4 and 5 and m_score between 3 and 5 then 'loyal customers'
when r_score between 4 and 5 and f_score between 2 and 3 and m_score between 2 and 4 then 'potential loyalists'
when r_score = 5 and f_score between 1 and 2 and m_score between 1 and 2 then 'recent customers'
when r_score between 3 and 4 and f_score between 1 and 2 and m_score between 1 and 2 then 'promising'
when r_score between 2 and 3 and f_score between 2 and 3 and m_score between 2 and 3 then 'needs attention'
when r_score between 1 and 2 and f_score between 3 and 5 and m_score between 3 and 5 then 'at risk'
when r_score = 1 and f_score between 4 and 5 and m_score between 4 and 5 then 'can’t lose them'
when r_score = 1 and f_score between 1 and 2 and m_score between 1 and 2 then 'hibernating'
else 'others'
end as segment
from rfm_scores;

