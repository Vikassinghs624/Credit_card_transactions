
#1- write a query to print top 5 cities with highest spends and their percentage contribution of total credit card spends 
with cte as (
select City, sum(Amount) as total_city_spends
from credit_card_transactions
group by City
Order by total_city_spends )
select City,total_city_spends,total_city_spends/(sum(total_city_spends) over())*100 as perc_contribution
from cte
order by perc_contribution desc
limit 5;

#2- write a query to print highest spend month and amount spent in that month for each card type
with cte as
(
select card_type,date_format(transaction_date,'%Y-%m') as spend_month ,sum(Amount) as total_month_spends
from credit_card_transactions
group by card_type,date_format(transaction_date,'%Y-%m')
order by  card_type,date_format(transaction_date,'%Y-%m'))

select *
from
(
select *,rank() over(partition by card_type order by total_month_spends desc) as rn
from cte) t
where t.rn=1;

#3- write a query to print the transaction details(all columns from the table) for each card type when
#it reaches a cumulative of 1000000 total spends(We should have 4 rows in the o/p one for each card type)
with commulative_spends as
(select * ,sum(Amount) over(partition by card_type order by transaction_date,serial_no) as comm_spend
from credit_card_transactions)
select * from 
commulative_spends
where comm_spend >= 1000000 ;


#4- write a query to find city which had lowest percentage spend for gold card type
with cte as (
select City, sum(Amount) as total_city_spends
from credit_card_transactions
where Card_Type='Gold'
group by City ),
yyyy as (
select City,total_city_spends,total_city_spends/(sum(total_city_spends) over())*100 as perc_contribution
from cte
order by perc_contribution desc)

select City,min(perc_contribution) as lowest_cont
from yyyy
group by City
order by min(perc_contribution) asc
limit 1;


#5- write a query to print 3 columns:  city, highest_expense_type ,
 # lowest_expense_type (example format : Delhi , bills, Fuel)

with cte as (
select city,exp_type, sum(amount) as total_amount from credit_card_transactions
group by city,exp_type)
select
city , max(case when rn_asc=1 then exp_type end) as lowest_exp_type
, min(case when rn_desc=1 then exp_type end) as highest_exp_type
from
(select *
,rank() over(partition by city order by total_amount desc) rn_desc
,rank() over(partition by city order by total_amount asc) rn_asc
from cte) A
group by city;




 

#6- write a query to find percentage contribution of spends by females for each expense type
with cte as (
select Exp_Type, sum(Amount) as exp_spends
from credit_card_transactions
where Gender='F'
group by Exp_Type
)
select Exp_Type,exp_spends,(exp_spends/(sum(exp_spends) over()))*100 as perc_contribution
from cte
order by perc_contribution desc;

#7- which card and expense type combination saw highest month over month growth in Jan-2014
with monthly_spending as
(
select Card_Type,Exp_Type,date_format(transaction_date,'%Y-%m') as spend_month,sum(Amount) as current_month_spends
from credit_card_transactions
group by Card_Type,Exp_Type,date_format(transaction_date,'%Y-%m')
)
select Card_Type,Exp_Type,((current_month_spends-prev_spend)/prev_spend) as mom_growth
from
(select *,lag(current_month_spends,1) over(partition by Card_Type,Exp_Type order by spend_month) as prev_spend
from monthly_spending ) t
where spend_month='2014-01' and prev_spend is not null
order by mom_growth desc
limit 1;


#9- during weekends which city has highest total spend to total no of transcations ratio 
select City,(sum(Amount)/count(transaction_date)) as ratio
from credit_card_transactions
where weekday(transaction_date) in (1,7)
group by City
order by ratio desc
limit 1;

#10- which city took least number of days to reach its 500th transaction after the first transaction in that city
with cte as
(
select * ,row_number() over(partition by City order by transaction_date,Serial_no) as rn
from credit_card_transactions)
select City,datediff(max(transaction_date),min(transaction_date)) as diff_days
from cte
where rn=1 or rn=500
group by City
having count(1)=2
order by diff_days 
limit 1;
