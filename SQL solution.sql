-- Фамилия Имя
-- Справочник сотрудников
create table Employee (
  ID int not null primary key,
  Code varchar(10) not null unique,
  Name varchar(255)
);

insert into Employee (ID, Code, Name)
values (1, 'E01', 'Ivanov Ivan Ivanovich'),
  (2, 'E02', 'Petrov Petr Petrovich'),
  (3, 'E03', 'Sidorov Sidr Sidorovich'),
  (4, 'E04', 'Semenov Semen Semenovich'),
  -- Полный тёзка сотрудника E02
  (5, 'E05', 'Petrov Petr Petrovich');

-- Отпуска сотрудников
create table Vacation (
  ID int not null auto_increment primary key,
  ID_Employee int not null references Employee(ID),
  DateBegin date not null,
  DateEnd date not null
);

insert into Vacation (ID_Employee, DateBegin, DateEnd)
values (1, '2019-08-10', '2019-09-01')
  ,(2, '2019-05-01', '2019-05-15')
  ,(1, '2019-12-29', '2020-01-14')
  ,(3, '2020-01-14', '2020-01-14')
  ,(4, '2021-02-01', '2021-02-14');

/* 
    Вывести коды и периоды отпусков сотрудников, которые были в отпуске одновременно в 2020 году
    Одновременный отпуск - когда хотя бы 1 день отпусков у двух сотрудников совпадает
    Дополнение:
    - в случае декретного отпуска сотрудник мог уйти в отпуск в 2019-ом году, а вернуться в 2021-ом
    На выходе:
    - таблица со столбцами (КодСотрудника1, НачалоОтпуска, КонецОтпуска, КодСотрудника2, НачалоОтпуска, КонецОтпуска)
    - должна вернуться одна строка с парой "E01 - E03". При этом "E03 - E01" - это дубль, которого не должно быть в итоговом результате
    Ограничения:
    - правильными считаются решения без использования конструкций "group by", "distinct"
    - нет дублирования кода
    - решение должно быть без использования вспомогательных функций greatest(), least()
    - засчитываются решения БЕЗ использования OR, CASE, CTE, подзапросов и создания дополнительных таблиц
*/

-- Выбираем отпуска сотрудников, которые пересекаются хотя бы на 1 день в 2020 году
select
    e1.Code as КодСотрудника1
    ,v1.DateBegin as НачалоОтпуска1
    ,v1.DateEnd as КонецОтпуска1
    ,e2.Code as КодСотрудника2
    ,v2.DateBegin as НачалоОтпуска2
    ,v2.DateEnd as КонецОтпуска2
from Vacation as v1
	-- Используем inner join для выбора только пересекающихся отпусков
	inner join Vacation v2 on v2.ID_Employee > v1.ID_Employee
		and v1.DateBegin <= v2.DateEnd
		and v1.DateEnd >= v2.DateBegin
		and 2020 between year(v1.DateBegin) and year(v1.DateEnd)
		and 2020 between year(v2.DateBegin) and year(v2.DateEnd)
    inner join Employee as e1 on e1.ID = v1.ID_Employee
    inner join Employee as e2 on e2.ID = v2.ID_Employee
where v1.ID_Employee < v2.ID_Employee
order by
    КодСотрудника1 
    ,НачалоОтпуска1 
    ,КодСотрудника2
    ,НачалоОтпуска2;
