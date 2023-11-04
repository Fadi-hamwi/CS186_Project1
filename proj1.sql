-- Before running drop any existing views
DROP VIEW IF EXISTS q0;
DROP VIEW IF EXISTS q1i;
DROP VIEW IF EXISTS q1ii;
DROP VIEW IF EXISTS q1iii;
DROP VIEW IF EXISTS q1iv;
DROP VIEW IF EXISTS q2i;
DROP VIEW IF EXISTS q2ii;
DROP VIEW IF EXISTS q2iii;
DROP VIEW IF EXISTS q3i;
DROP VIEW IF EXISTS q3ii;
DROP VIEW IF EXISTS q3iii;
DROP VIEW IF EXISTS q4i;
DROP VIEW IF EXISTS q4ii;
DROP VIEW IF EXISTS q4iii;
DROP VIEW IF EXISTS q4iv;
DROP VIEW IF EXISTS q4v;

-- Question 0
CREATE VIEW q0(era)
AS
  SELECT max(era) from pitching;
;

-- Question 1i
CREATE VIEW q1i(namefirst, namelast, birthyear)
AS
  select namefirst, namelast, birthyear 
  from people 
  where weight > 300;
;

-- Question 1ii
CREATE VIEW q1ii(namefirst, namelast, birthyear)
AS
  select namefirst, namelast, birthyear
  from people
  where namefirst like '% %'
  order by namefirst, namelast;
;

-- Question 1iii
CREATE VIEW q1iii(birthyear, avgheight, count)
AS
  select birthyear, avg(height) as avgheight, count(*) as count
  from people
  group by birthyear
  order by birthyear asc;
;

-- Question 1iv
CREATE VIEW q1iv(birthyear, avgheight, count)
AS
  select birthyear, avg(height) as avgheight, count(*) as count
  from people
  group by birthyear
  having avg(height) > 70
  order by birthyear asc;
;

-- Question 2i
CREATE VIEW q2i(namefirst, namelast, playerid, yearid)
AS
  select namefirst, namelast, p.playerid, yearid
  from people p inner join halloffame hf
  on p.playerid = hf.playerid 
  where hf.inducted = 'Y'
  order by hf.yearid desc, p.playerid asc;
;

-- Question 2ii
CREATE VIEW q2ii(namefirst, namelast, playerid, schoolid, yearid)
AS
  select namefirst, namelast, people.playerid, schools.schoolid, yearid
  from people, halloffame, collegeplaying, schools
  where people.playerid = halloffame.playerid and halloffame.playerid = collegeplaying.playerid and inducted='Y' and schools.schoolid = collegeplaying.schoolid and schoolState='CA'
  order by yearid desc, schools.schoolid asc, people.playerid asc;  
;

-- Question 2iii
CREATE VIEW q2iii(playerid, namefirst, namelast, schoolid)
AS
  select people.playerid, namefirst, namelast, collegeplaying.schoolid
  from people join halloffame on people.playerid = halloffame.playerid left outer join collegeplaying on collegeplaying.playerid = people.playerid 
  where inducted='Y'
  order by people.playerid desc, collegeplaying.schoolid asc;
;

-- Question 3i
CREATE VIEW q3i(playerid, namefirst, namelast, yearid, slg)
AS
  select people.playerid, namefirst, namelast, yearid,  (H + H2B+2*H3B+3*HR+0.0)/(AB+0.0) as slg
  from people, batting
  where people.playerid = batting.playerid and AB > 50
  order by slg desc, yearid asc, batting.playerid asc
  limit 10;
;

-- Question 3ii
CREATE VIEW lslg(playerid, l)
AS
  SELECT playerid, (sum(H) + sum(H2B) + sum(2*H3B) + sum(3*HR) + 0.0)/ sum(AB) as l
  FROM batting 
  GROUP BY playerid
  HAVING SUM(AB) > 50;
;

CREATE VIEW q3ii(playerid, namefirst, namelast, lslg)
AS
  select people.playerid, namefirst, namelast, l as lslg
  from people, lslg
  where people.playerid = lslg.playerid 
  order by lslg.l desc, people.playerid asc
  limit 10;
;

-- Question 3iii

CREATE VIEW q3iii(namefirst, namelast, lslg)
AS
  select namefirst, namelast, l  as lslg
  from people, lslg
  where people.playerid = lslg.playerid and 
  lslg.l > (select (sum(H) + sum(H2B) + sum(2*H3B) + sum(3*HR) + 0.0)/ sum(AB) from batting where playerid='mayswi01' group by playerid);
;

-- Question 4i
CREATE VIEW q4i(yearid, min, max, avg)
AS
  SELECT yearid, MIN(salary) as min, MAX(salary) as max, AVG(salary) as avg
  from salaries
  group by yearid 
  order by yearid;
;

-- Question 4ii
CREATE VIEW q4ii(binid, low, high, count)
AS
  SELECT binid, 507500.0+binid*3249250,3756750.0+binid*3249250, count(*)
  from binids,salaries
  where (salary between 507500.0+binid*3249250 and 3756750.0+binid*3249250 )and yearID='2016'
  group by binid
;

-- Question 4iii
CREATE VIEW q4iii(yearid, mindiff, maxdiff, avgdiff)
AS
SELECT
    s1.yearid,
    s1.min_salary - s2.min_salary AS mindiff,
    s1.max_salary - s2.max_salary AS maxdiff,
    s1.avg_salary - s2.avg_salary AS avgdiff
FROM
    (
        SELECT
            yearid,
            MIN(salary) AS min_salary,
            MAX(salary) AS max_salary,
            AVG(salary) AS avg_salary
        FROM
            salaries
        GROUP BY
            yearid
    ) s1
JOIN
    (
        SELECT
            yearid,
            MIN(salary) AS min_salary,
            MAX(salary) AS max_salary,
            AVG(salary) AS avg_salary
        FROM
            salaries
        GROUP BY
            yearid
    ) s2
ON
    s1.yearid = s2.yearid + 1
WHERE
    s1.yearid > (SELECT MIN(yearid) FROM salaries)
ORDER BY
    s1.yearid ASC;


;

-- Question 4iv
CREATE VIEW q4iv(playerid, namefirst, namelast, salary, yearid)
AS
  select p.playerid, namefirst, namelast, salary, yearid
  from people p inner join salaries s on p.playerid = s.playerid 
  where yearid in ('2000', '2001') 
  group by p.playerid, namefirst, namelast, salary, yearid 
  having salary in (select max(salary) from salaries where s.yearid = yearid);
;
-- Question 4v
CREATE VIEW q4v(team, diffAvg) AS
  select a.teamid as team, max(salary) - min(salary) as diffAvg
  from salaries s, allstarfull a 
  where s.playerid = a.playerid and s.yearid = a.yearid and s.yearid = '2016'
  group by a.teamid
;

