--1--

SELECT DISTINCT people.playerID as playerid, nameFirst as firstname,nameLast as lastname , 
(COALESCE(SUM(Batting.CS),0)) as  total_caught_stealing
FROM People , Batting
WHERE People.playerID = Batting.playerID
GROUP BY people.playerID , firstname , lastname
ORDER BY total_caught_stealing desc , firstname asc , lastname asc , playerid  asc
LIMIT 10;

--2--

SELECT DISTINCT people.playerID as playerid, nameFirst as firstname , 
(2*COALESCE(SUM(Batting.H2B),0) + 3*COALESCE(SUM(Batting.H3B),0) + 4*COALESCE(SUM(Batting.HR),0)) as  runscore
FROM People , Batting
WHERE People.playerID = Batting.playerID
GROUP BY people.playerID , firstname
ORDER BY runscore desc , firstname desc ,playerid  asc
LIMIT 10;

--3--
SELECT DISTINCT people.playerID as playerid , 
	CASE 
		WHEN (nameFirst IS NOT NULL) AND (nameLast IS NOT NULL)  THEN (nameFirst || ' ' || nameLast) 
		WHEN (nameFirst IS NOT NULL) THEN nameFirst 
		WHEN (nameLast IS NOT NULL) THEN nameLast 
		ELSE '' 
		END as playername 
, COALESCE(SUM(AwardsSharePlayers.pointsWon),0) as total_points
FROM People , AwardsSharePlayers
WHERE People.playerID = AwardsSharePlayers.playerID AND AwardsSharePlayers.yearID >= 2000
GROUP by people.playerID , nameFirst,nameLast
ORDER BY total_points desc , playerid asc;

--4--
WITH Avearge(playerid , yearID, Batavg) AS (
	SELECT playerid,yearID , (SUM(Batting.H)*1.0)/(SUM(Batting.AB)*1.0) as  Batavg
	FROM Batting
	WHERE Batting.AB IS NOT NULL AND Batting.AB <> 0 
	AND Batting.H IS NOT NULL
	GROUP BY playerid,yearID
	)

SELECT DISTINCT People.playerID as playerid , nameFirst as firstname , nameLast as lastname , 
AVG(Batavg) as career_batting_average
FROM People, Avearge
WHERE People.playerID = Avearge.playerID 
GROUP BY People.playerID,firstname,lastname
HAVING COUNT(DISTINCT yearID)>=10
ORDER BY career_batting_average desc , playerID asc,firstname asc, lastname asc
LIMIT 10;

--5--

SELECT DISTINCT T.playerID as playerid, nameFirst as firstname, nameLast as lastname,
CASE
WHEN (birthDay IS NULL) OR (birthYear IS NULL) OR (birthMonth IS NULL)
THEN  ''
ELSE
to_char((to_date(to_char(birthYear,'9999')||to_char(birthMonth,'9999')||to_char(birthDay,'9999'), 
	'YYYY MM DD')), 'YYYY-MM-DD')
END
as  date_of_birth,
(SELECT COUNT(*) FROM
	(
		(SELECT yearID FROM Batting WHERE Batting.playerid = T.playerID)  UNION
		(SELECT yearID FROM Fielding WHERE Fielding.playerid = T.playerID) UNION
		(SELECT yearID FROM Pitching WHERE Pitching.playerid = T.playerID)
	) AS T1
)
as num_seasons
FROM People as T
WHERE (SELECT COUNT(*) FROM
	(
			(SELECT yearID FROM Batting WHERE Batting.playerid = T.playerID)  UNION
			(SELECT yearID FROM Fielding WHERE Fielding.playerid = T.playerID) UNION
			(SELECT yearID FROM Pitching WHERE Pitching.playerid = T.playerID)
		) AS T1
	)>0
ORDER BY num_seasons desc , playerid asc , firstname asc , lastname asc , date_of_birth asc;

--6--
WITH WINS(teamid , num_wins) AS (
		SELECT DISTINCT teamID as teamid, MAX(Teams.W)as num_wins
		FROM Teams
		WHERE Teams.DivWin = 't'
		GROUP BY teamid
	),
	Latest(teamid, yearid, lgid ,ranking) AS(
		SELECT teamID as teamid, yearID,lgID,
			rank() OVER (PARTITION BY teamid ORDER BY yearID desc,lgID desc) as ranking
		FROM Teams
	),
	Latestname(teamid ,teamname) AS (
		SELECT Teams.teamID , name as teamname
		FROM Teams 
		JOIN Latest ON (Latest.teamid = Teams.teamid AND Latest.yearid=Teams.yearID
			AND Latest.lgID = Teams.lgID)
		WHERE ranking = 1
	)

SELECT DISTINCT Teams.teamID as teamid, teamname, franchName as franchisename, num_wins
	FROM Teams
	 NATURAL JOIN TeamsFranchises 
	JOIN WINS ON (Teams.teamid = WINS.teamid)
	JOIN Latestname ON(Teams.teamid = Latestname.teamid)
	WHERE Teams.DivWin = 't'
	ORDER BY num_wins desc , teamid asc , teamname asc , franchisename asc;

--7--

CREATE VIEW T1 AS 
	SELECT teamID as teamid,name as teamname,
	COALESCE(MAX((W*1.0)/(G*1.0)),0)*100.00 as winning_percentage
	FROM Teams
	GROUP BY teamid,teamname
	HAVING COALESCE(SUM(W),0)>=20
	ORDER BY winning_percentage desc , teamid asc , teamname asc
	LIMIT 5 ;

SELECT DISTINCT T1.teamID as teamid , name as teamname , T2.yearID as seasonid, winning_percentage
FROM T1,Teams as T2
WHERE T1.teamid = T2.teamid AND T1.teamname = T2.name AND
((T2.W*1.0)/(T2.G*1.0))*100.00 = T1.winning_percentage
ORDER BY winning_percentage desc , T1.teamid asc , name asc, seasonid asc;

--8--

WITH MAXISALARY(teamid,yearID,salary) AS (
		SELECT Salaries.teamid , Salaries.yearID, COALESCE(max(salary),0) as salary
		FROM Salaries
		GROUP BY Salaries.teamid,Salaries.yearID
	),
	Latest(teamid, yearid, lgid ,ranking) AS(
		SELECT teamID as teamid, yearID,lgID,
			rank() OVER (PARTITION BY teamid ORDER BY yearID desc,lgID desc) as ranking
		FROM Teams
	),
	Latestname(teamid ,teamname) AS (
		SELECT Teams.teamID , name as teamname
		FROM Teams 
		JOIN Latest ON (Latest.teamid = Teams.teamid AND Latest.yearid=Teams.yearID
			AND Latest.lgID = Teams.lgID)
		WHERE ranking = 1
	),
	MAXPEOPLE(teamID , yearID , salary ,playerID) AS (
		SELECT M.teamID,M.yearID,M.salary,S.playerID
		FROM MAXISALARY as M
		JOIN Salaries as S ON (M.teamid = S.teamid AND M.yearID = S.yearID
		AND M.salary = S.salary)
	)

SELECT DISTINCT MAXPEOPLE.teamID as teamid , teamname , MAXPEOPLE.yearID as seasonid,
People.playerID as playerid,
nameFirst as player_firstname , nameLast as player_lastname , MAXPEOPLE.salary
FROM MAXPEOPLE JOIN People ON (MAXPEOPLE.playerid = People.playerID)
	JOIN Latestname ON (MAXPEOPLE.teamid = Latestname.teamid)
ORDER BY teamid asc, teamname asc , seasonid asc , playerid asc , player_firstname asc ,
player_lastname asc , salary desc;

--9--

WITH BAT(salary) AS (
	SELECT AVG(salary)
	FROM Salaries NATURAL JOIN Batting
	),
	PITCH(salary) AS (
	SELECT AVG(salary)
	FROM Salaries NATURAL JOIN Pitching
	)

SELECT 
CASE 
	WHEN BAT.salary>PITCH.salary THEN 'batsman'
	ELSE 'pitcher'
	END as player_category,
CASE
	WHEN BAT.salary>PITCH.salary THEN BAT.salary
	ELSE PITCH.salary
	END as avg_salary
FROM BAT,PITCH;

--10--

SELECT P1.playerID as playerid , 
	CASE 
		WHEN (P1.nameFirst IS NOT NULL) AND (P1.nameLast IS NOT NULL)  
		THEN (P1.nameFirst || ' ' || P1.nameLast) 
		WHEN (P1.nameFirst IS NOT NULL) THEN P1.nameFirst 
		WHEN (P1.nameLast IS NOT NULL) THEN P1.nameLast
		ELSE ''
		END as playername , 
	COUNT(DISTINCT P2.playerID) as number_of_batchmates
FROM People as P1 NATURAL JOIN CollegePlaying as C1,
	People as P2 NATURAL JOIN CollegePlaying as C2
WHERE C1.yearID = C2.yearID AND C1.schoolID = C2.schoolID AND P1.playerID <> P2.playerID
GROUP BY P1.playerID,playername
ORDER BY number_of_batchmates desc , P1.playerid asc;

--11--

WITH Latest(teamid, yearid, lgid ,ranking) AS(
		SELECT teamID as teamid, yearID,lgID,
			rank() OVER (PARTITION BY teamid ORDER BY yearID desc,lgID desc) as ranking
		FROM Teams
	),
	Latestname(teamid ,teamname) AS (
		SELECT Teams.teamID , name as teamname
		FROM Teams 
		JOIN Latest ON (Latest.teamid = Teams.teamid AND Latest.yearid=Teams.yearID
			AND Latest.lgID = Teams.lgID)
		WHERE ranking = 1
	) ,
	CNTWS(teamid , total_WS_wins) AS(
		SELECT teamID as teamid , COUNT(*) as total_WS_wins
		FROM Teams
		WHERE Teams.G >= 110 AND Teams.WSWIN = 't'
		GROUP BY teamid
	)

SELECT DISTINCT CNTWS.teamid as teamid , teamname , total_WS_wins
FROM Latestname JOIN CNTWS ON (Latestname.teamid=CNTWS.teamid)
ORDER BY total_WS_wins desc , teamid asc , teamname asc
LIMIT 5;

--12--

SELECT People.playerID as playerid , namefirst as firstname, nameLast as lastname, 
COALESCE(SUM(Pitching.SV) , 0) as career_saves , COUNT(DISTINCT yearID) as num_seasons
FROM Pitching NATURAL JOIN People
GROUP BY People.playerID, firstname,lastname
HAVING COUNT(DISTINCT yearID)>=15
ORDER BY career_saves desc , num_seasons desc , People.playerid asc , firstname asc , lastname asc
LIMIT 10;

--13--

WITH Valid_Pitchers(playerid) AS (
		SELECT playerid
		FROM Pitching
		GROUP BY playerid
		HAVING COUNT(DISTINCT teamID) >= 5
	),
	Ranking(playerid , teamid, yearid,stint ,ranking) AS (
		SELECT Pitching.playerid, teamid , yearID,stint,
		rank() OVER (PARTITION BY Pitching.playerid,teamid ORDER BY yearID,stint) as ranking
		FROM Pitching JOIN Valid_Pitchers ON (Valid_Pitchers.playerid = Pitching.playerID)
	),
	Earliest(playerid,teamid,yearID,stint) AS (
		SELECT playerid,teamid,yearID,stint
		FROM Ranking
		WHERE ranking = 1
	),
	Ranking1(playerid,teamid, ranking) AS (
		SELECT playerid,teamid , 
		rank() OVER (PARTITION BY playerid ORDER BY yearID,stint) as ranking
		FROM Earliest
	),
	E1(playerid,teamid) AS (
		SELECT playerid,teamid
		FROM Ranking1
		WHERE ranking = 1
	),
	E2(playerid,teamid) AS (
		SELECT playerid,teamid
		FROM Ranking1
		WHERE ranking = 2
	),
	Latest(teamid, yearid, lgid ,ranking) AS(
		SELECT teamID as teamid, yearID,lgID,
			rank() OVER (PARTITION BY teamid ORDER BY yearID desc,lgID desc) as ranking
		FROM Teams
	),
	Latestname(teamid ,teamname) AS (
		SELECT Teams.teamID , name as teamname
		FROM Teams 
		JOIN Latest ON (Latest.teamid = Teams.teamid AND Latest.yearid=Teams.yearID
			AND Latest.lgID = Teams.lgID)
		WHERE ranking = 1
	),
	E1name(playerid,first_teamname) AS(
		SELECT playerid,teamname as first_teamname
		FROM E1 JOIN Latestname ON (E1.teamid = Latestname.teamid)
	),
	E2name(playerid, second_teamname) AS(
		SELECT playerid,teamname as  second_teamname
		FROM E2 JOIN Latestname ON (E2.teamid = Latestname.teamid)
	),
	BirthInfo(playerid, birth_address) AS (
		SELECT playerid , 
		CASE WHEN birthCountry is not null AND birthCity is not null AND birthState is not null
		THEN (LOWER(birthCity || ' ' || birthState || ' ' || birthCountry))
		ELSE ''
		END AS birth_address
		FROM People
	)

SELECT P.playerid as playerid , nameFirst as firstname, nameLast as lastname, birth_address,
	first_teamname ,  second_teamname
FROM People as P JOIN BirthInfo ON (P.playerid = BirthInfo.playerID)
	 JOIN E1name ON (E1name.playerid = P.playerid)
	 JOIN E2name ON (E2name.playerid = P.playerid)
ORDER BY P.playerid asc , firstname asc ,lastname asc , birth_address asc , first_teamname asc
,second_teamname asc ;


--14--
BEGIN TRANSACTION;
INSERT INTO People (playerid,namefirst,nameLast) VALUES ('dunphil02','Phil','Dunphy');
INSERT INTO AwardsPlayers (awardID,yearID, lgID, playerid,tie)
VALUES ('Best Baseman' , 2014 , '','dunphil02','t') ;

INSERT INTO People (playerid,namefirst,nameLast) VALUES ('tuckcam01','Cameron','Tucker');
INSERT INTO AwardsPlayers (awardID,yearID, lgID, playerid,tie)
VALUES ('Best Baseman' , 2014 , '','tuckcam01','t') ;

INSERT INTO People (playerid,namefirst,nameLast) VALUES ('scottm02','Michael','Scott');
INSERT INTO AwardsPlayers (awardID,yearID, lgID, playerid,tie)
VALUES ('ALCS MVP' , 2015 , 'AA','scottm02','f') ;

INSERT INTO People (playerid,namefirst,nameLast) VALUES ('waltjoe','Joe','Walt');
INSERT INTO AwardsPlayers (awardID,yearID, lgID, playerid)
VALUES ('Triple Crown' , 2016 , '','waltjoe') ;

INSERT INTO AwardsPlayers (awardID,yearID, lgID, playerid,tie)
VALUES ('Gold Glove' , 2017 , '','adamswi01','f') ;

INSERT INTO AwardsPlayers (awardID,yearID, lgID, playerid)
VALUES ('ALCS MVP' , 2017 , '','yostne01') ;
END TRANSACTION;

WITH NumAward(awardID , playerID , num_wins) AS (
		SELECT awardID, playerID, COUNT(*) as num_wins
		FROM AwardsPlayers
		GROUP BY awardID,playerid
	),
	MaxiAward(awardID, num_wins) AS (
		SELECT A.awardID , MAX(num_wins) 
		FROM AwardsPlayers AS A 
		JOIN NumAward AS N ON (A.awardID = N.awardID AND A.playerID = N.playerID)
		GROUP BY A.awardID
	),
	MaxiPlayer(awardID,playerid,num_wins) AS (
		SELECT N.awardID,MIN(N.playerid),N.num_wins
		FROM NumAward as N JOIN MaxiAward as M ON (M.awardID = N.awardID
			AND M.num_wins = N.num_wins)
		GROUP by N.awardid,N.num_wins
	)

SELECT M.awardID as awardid , P.playerID as playerid , nameFirst as firstname , namelast as lastname,
	num_wins
FROM People as P JOIN MaxiPlayer as M ON (P.playerid = M.playerID)
ORDER BY awardID asc , num_wins desc;


--15--

WITH first(teamid,yearID,managerialID) AS(
		SELECT teamID,yearID, min(inseason) as managerialID
		FROM Managers
		WHERE yearID BETWEEN 2000 AND 2010
		GROUP BY teamid,yearID
	),
	firstManager(teamid,seasonid,managerid) AS (
		SELECT M.teamID,M.yearID as seasonid, M.playerid as managerid
		FROM Managers as M JOIN 
			first ON(first.teamid = M.teamid AND first.yearID = M.yearID
			AND first.managerialID = M.inseason)
	),
	Latest(teamid, yearid, lgid ,ranking) AS(
		SELECT teamID as teamid, yearID,lgID,
			rank() OVER (PARTITION BY teamid ORDER BY yearID desc,lgID desc) as ranking
		FROM Teams
	),
	Latestname(teamid ,teamname) AS (
		SELECT Teams.teamID , name as teamname
		FROM Teams 
		JOIN Latest ON (Latest.teamid = Teams.teamid AND Latest.yearid=Teams.yearID
			AND Latest.lgID = Teams.lgID)
		WHERE ranking = 1
	)

SELECT F.teamID as teamid, teamname, seasonid,managerid,namefirst as managerfirstname, 
		nameLast as managerlastname
FROM firstManager as F JOIN People ON (People.playerid =  F.managerid) 
	 JOIN Latestname ON (Latestname.teamid = F.teamid)
ORDER BY teamid asc , teamname asc , seasonid desc , managerid asc , managerfirstname asc ,
	managerlastname asc;

--16--

WITH num_awards(total_awards) AS (
		SELECT COUNT(*) as total_awards
		FROM AwardsPlayers
		GROUP BY playerid 
		ORDER BY total_awards desc
		LIMIT 10
	),
	min_award(num_awards) AS (
		SELECT min(total_awards) FROM num_awards
	),
	Top_players(playerid,total_awards) AS (
		SELECT playerid,COUNT(*) AS total_awards
		FROM AwardsPlayers,min_award
		GROUP BY playerid,num_awards
		HAVING COUNT(*)>= num_awards
	),
	last_year(playerid, yearID) AS (
		SELECT playerid, MAX(yearID)
		FROM CollegePlaying
		GROUP BY playerid
	),
	last_college(playerid,schoolID) AS (
		SELECT P.playerid,
			CASE WHEN last_year.yearID is NULL THEN ''
			ELSE (SELECT schoolID FROM CollegePlaying as C WHERE C.playerid = P.playerid
				AND C.yearID = last_year.yearID)
			END AS schoolID
		FROM Top_players  as P LEFT JOIN last_year ON (P.playerid = last_year.playerid)
	),
	last_college_name(playerid,colleges_name) AS (
		SELECT playerid,schoolName as colleges_name
		FROM last_college as L
			LEFT JOIN Schools ON (L.schoolID = Schools.schoolID)
	)

SELECT T.playerid , colleges_name , total_awards
FROM Top_players as T 
	JOIN last_college_name as L ON (T.playerid = L.playerid)
ORDER BY total_awards desc , colleges_name asc , playerid asc
LIMIT 10;

--17--

WITH Valid_People(playerid) AS (
	SELECT * FROM (
		(SELECT playerid FROM AwardsPlayers)
		INTERSECT
		(SELECT playerid FROM AwardsManagers)
		) AS T
	),
	
	ManagerAward(playerid ,  managerawardyear, managerawardid , ranking) AS (
		SELECT P.playerid as playerid , yearID as managerawardyear, awardID as managerawardid
			, rank() OVER (PARTITION BY AM.playerid ORDER BY AM.yearID asc, AM.awardID asc)
			as ranking
		FROM Valid_People as P 
			JOIN AwardsManagers as AM ON (P.playerid = AM.playerid)
	),
	PlayerAward(playerid ,  playerawardyear, playerawardid , ranking) AS (
		SELECT P.playerid as playerid , yearID as playerawardyear, awardID as playerawardid
			, rank() OVER (PARTITION BY AP.playerid ORDER BY AP.yearID asc, AP.awardID asc)
			as ranking
		FROM Valid_People as P 
			JOIN AwardsPlayers as AP ON (P.playerid = AP.playerid)
	),
	FirstManagerAward(playerid ,  managerawardyear, managerawardid) AS (
		SELECT DISTINCT playerid , managerawardyear, managerawardid
		FROM ManagerAward
		WHERE ranking = 1
	),
	FirstPlayerAward(playerid ,  playerawardyear, playerawardid) AS (
		SELECT DISTINCT playerid , playerawardyear, playerawardid
		FROM PlayerAward
		WHERE ranking = 1
	)

SELECT P.playerid as playerid , nameFirst as firstname , nameLast as lastname , playerawardid,playerawardyear
	,managerawardid,managerawardyear
FROM People as P JOIN FirstManagerAward as FM ON (P.playerid = FM.playerid)
	 JOIN FirstPlayerAward as FP ON (P.playerid = FP.playerid)
ORDER BY playerid asc , firstname asc , lastname asc;

--18--

WITH Valid_People(playerid) AS (
		SELECT DISTINCT playerid FROM (
			(SELECT playerid FROM HallOfFame GROUP BY playerid HAVING COUNT(DISTINCT category)>=2) 
			INTERSECT
			(SELECT DISTINCT playerid FROM AllstarFull WHERE GP = 1)
		) AS T
	),
	FirstSeason(playerid , seasonid) AS (
		SELECT P.playerid , MIN(yearID) as seasonid
		FROM Valid_People as P JOIN AllstarFull as AF ON (P.playerid = AF.playerid AND AF.GP = 1)
		GROUP BY P.playerid
	),
	Categories(playerid,num_honored_categories) AS (
		SELECT P.playerid , COUNT(DISTINCT category) as num_honored_categories
		FROM Valid_People as P JOIN HallOfFame as HF ON (P.playerid = HF.playerid)
		GROUP BY P.playerid
	)

SELECT P.playerid as playerid , nameFirst as firstname , namelast as lastname , 
	num_honored_categories,seasonid
FROM People as P JOIN FirstSeason as FS ON (P.playerid = FS.playerid) 
	 JOIN Categories as C ON (P.playerID = C.playerid)
ORDER BY num_honored_categories desc,playerID asc,firstname asc ,lastname asc ,seasonid asc;


--19--

WITH Count(playerid, G_1b , G_2b, G_3b, G_all) AS (
		SELECT playerid ,COALESCE(SUM(G_1b),0) as G_1b, COALESCE(SUM(G_2b),0) as G_2b, 
			   COALESCE(SUM(G_3b),0) as G_3b , COALESCE(SUM(G_all),0) as G_all
		FROM Appearances
		GROUP BY playerid
	),
	Valid_People(playerid , G_1b , G_2b, G_3b, G_all) AS (
		SELECT playerid,G_1b , G_2b, G_3b, G_all
		FROM COUNT
		WHERE 
			(((G_1b + G_2b + G_3b) <> G_1b) AND ((G_1b + G_2b + G_3b) <> G_2b) AND 
			((G_1b + G_2b + G_3b) <> G_3b))
	)

SELECT P.playerid, nameFirst as firstname , nameLast as lastname , G_all, G_1b , G_2b , G_3b
FROM Valid_People as V JOIN People as P ON (V.playerid = P.playerid)
ORDER BY G_all desc , playerid asc , firstname asc , lastname asc , G_1b desc ,  G_2b desc
	,G_3b desc; 

--20--

WITH Valid_Schools(schoolID,schoolName,schooladdr) AS(
	SELECT Schools.schoolID  as schoolID, schoolName, 
		CASE 
			WHEN (schoolcity is not null and schoolstate is not null) 
			THEN (LOWER(schoolcity || ' ' || schoolstate))
			ELSE ''
		END as schooladdr
	FROM CollegePlaying JOIN Schools ON (CollegePlaying.schoolID = Schools.schoolID)
	GROUP BY Schools.schoolID, schoolName , schoolcity , schoolstate
	ORDER BY COUNT(DISTINCT playerid) desc
	LIMIT 5
)
SELECT DISTINCT V.schoolID as schoolID ,V.schoolName as schoolName,  
	schooladdr, P.playerid,nameFirst as firstname , nameLast as lastname
FROM Valid_Schools as V JOIN CollegePlaying ON (V.schoolID = CollegePlaying.schoolID)
	JOIN People as P ON (CollegePlaying.playerid = P.playerid)
ORDER BY schoolID asc, schoolName asc,schooladdr asc,playerid asc ,firstname asc,lastname asc;


--21--

WITH Valid_People(playerid,birthCity,birthState) AS (
	SELECT playerid,birthCity,birthState
	FROM People
	WHERE birthCity IS NOT NULL AND birthState IS NOT NULL
),
SameAddr(player1_id ,  player2_id,birthcity,birthstate) AS(
	SELECT P1.playerid as player1_id , P2.playerid as player2_id,P1.birthCity as birthcity , 
		P2.birthState as birthstate
	FROM Valid_People as P1 
		JOIN Valid_People as P2 ON (P1.birthCity = P2.birthCity AND P1.birthState = P2.birthState
			AND P1.playerid <> P2.playerID)
),
SamePitched(player1_id,player2_id,birthcity,birthstate) AS (
	SELECT player1_id , player2_id ,birthCity,birthState
	FROM SameAddr
	WHERE EXISTS(
		(
			SELECT DISTINCT teamID
			FROM Pitching
			WHERE playerid = player1_id
		)
		INTERSECT
		(
			SELECT DISTINCT teamID
			FROM Pitching
			WHERE playerid = player2_id
		)
	)
),
SameBatted(player1_id,player2_id,birthcity,birthstate) AS (
	SELECT player1_id, player2_id,birthcity,birthstate
	FROM SameAddr
	WHERE EXISTS(
		(
			SELECT DISTINCT teamID
			FROM Batting
			WHERE playerid = player1_id
		)
		INTERSECT
		(
			SELECT DISTINCT teamID
			FROM Batting
			WHERE playerid = player2_id
		)
	)
),
Both_role(player1_id,player2_id,birthcity,birthstate,role) AS (
	SELECT player1_id,player2_id ,birthcity,birthstate,
		CASE WHEN TRUE THEN 'both' END as role
	FROM
		((SELECT player1_id,player2_id,birthcity,birthstate
		FROM SameBatted)
		INTERSECT
		(SELECT player1_id,player2_id,birthcity,birthstate
		FROM SamePitched)) AS T
),
Bat_role(player1_id,player2_id,birthcity,birthstate,role) AS (
	SELECT player1_id,player2_id ,birthcity,birthstate,
		CASE WHEN TRUE THEN 'batted' END as role
	FROM
		((SELECT player1_id,player2_id,birthcity,birthstate
		FROM SameBatted)
		EXCEPT
		(SELECT player1_id,player2_id,birthcity,birthstate
		FROM Both_role)) AS T
),
Pitch_role(player1_id,player2_id,birthcity,birthstate,role) AS (
	SELECT player1_id,player2_id ,birthcity,birthstate,
		CASE WHEN TRUE THEN 'pitched' END as role
	FROM
		((SELECT player1_id,player2_id,birthcity,birthstate
		FROM SamePitched)
		EXCEPT
		(SELECT player1_id,player2_id,birthcity,birthstate
		FROM Both_role)) AS T
)

SELECT player1_id,player2_id,birthcity,birthstate,role
FROM (
	(SELECT *
	FROM Both_role)
	UNION
	(SELECT *
	FROM Bat_role)
	UNION
	(SELECT *
	FROM
	Pitch_role)

) AS T
ORDER BY birthcity asc,birthstate asc,player1_id asc,player2_id asc;

--22--

WITH AvgPoints(averagepoints,awardID,yearID) AS(
	SELECT AVG(pointsWon) AS averagepoints,awardID,yearID
	FROM AwardsSharePlayers
	GROUP BY awardID,yearID
),
PointsPlayer(playerid,awardID,yearID,playerpoints) AS(
	SELECT playerid,awardID,yearID,COALESCE(SUM(pointsWon),0) as playerpoints
	FROM AwardsSharePlayers
	GROUP BY awardID,yearID,playerid
)
SELECT DISTINCT pp.awardID,pp.yearID as seasonid,playerid,playerpoints,averagepoints
FROM AvgPoints as ap
	JOIN PointsPlayer as pp ON(ap.awardID = pp.awardID AND ap.yearid = pp.yearID)
WHERE ap.averagepoints<=pp.playerpoints
ORDER BY awardID asc , seasonid asc, playerpoints desc , playerid asc; 

--23--

WITH Valid_People_temp(playerid) AS (
	SELECT DISTINCT playerid 
	FROM(
	(SELECT playerid FROM People)
	EXCEPT 
	(SELECT playerid FROM AwardsPlayers)) AS T
),
Valid_People(playerid) AS (
	SELECT DISTINCT playerid 
	FROM(
	(SELECT playerid FROM Valid_People_temp)
	EXCEPT 
	(SELECT playerid FROM AwardsManagers)) AS T
)
SELECT People.playerid as player1_id,
	CASE 
		WHEN (nameFirst IS NOT NULL) AND (nameLast IS NOT NULL)  THEN (nameFirst || ' ' || nameLast) 
		WHEN (nameFirst IS NOT NULL) THEN nameFirst 
		WHEN (nameLast IS NOT NULL) THEN nameLast 
		ELSE '' 
		END as playername
	,
	CASE
	 	WHEN (deathYear IS NULL AND deathday IS NULL AND deathmonth IS NULL) THEN TRUE
	 	ELSE FALSE
	 	END as alive
FROM Valid_People JOIN People ON(Valid_People.playerid=People.playerID)
ORDER BY People.playerid asc , playername asc;

--24--
WITH RECURSIVE Connected(playerid1 ,playerid2,length,weight,route,cycle) AS (
	SELECT S.playerid1,S.playerid2, CAST(0 AS bigint),S.weight,
		ARRAY[S.playerid1::text],false
	FROM Graph as S
	WHERE S.playerid1 = 'webbbr01'
	UNION ALL
	SELECT S.playerid1,S.playerid2 ,C.weight + length, S.weight, 
		route || (S.playerid1::text),
		S.playerid1 = ANY(route)
	FROM Graph as S, Connected as C
	WHERE S.playerid1 = C.playerid2 AND NOT cycle

),
Valid_People(playerid,yearID,teamid) AS (
	SELECT DISTINCT playerid ,yearID ,teamid FROM(
		(SELECT playerid,yearID,teamid FROM Pitching)
		UNION
		(SELECT playerid,yearID,teamid FROM AllstarFull WHERE GP = 1)
	) AS T
),
Edges(playerid1,playerid2,teamid,yearID) AS (
	SELECT V1.playerid as  playerid1,V2.playerid as playerid2,V1.teamid as teamid,
		V1.yearID as yearID
	FROM Valid_People as V1 
		JOIN Valid_People as V2 ON (V1.teamid = V2.teamid AND V1.yearID = V2.yearID)
	WHERE V1.playerid <> V2.playerid
),
Graph(playerid1,playerid2,weight) AS (
	SELECT playerid1,playerid2,weight 
	FROM
	(
		(
			SELECT playerid1,playerid2, COUNT(*) AS weight
			FROM Edges
			GROUP BY playerid1,playerid2
		)
		UNION
		(
			SELECT playerid2,playerid1, COUNT(*) AS weight
			FROM Edges
			GROUP BY playerid1,playerid2
		)
	) AS T
)

SELECT CASE WHEN EXISTS(
	select playerid2
	FROM Connected
	WHERE playerid2 = 'clemero02'
		AND length>=3) THEN TRUE ELSE FALSE 
	END as pathexists;

--25--
WITH RECURSIVE Connected(playerid1 ,playerid2,length,weight,route,cycle) AS (
	SELECT S.playerid1,S.playerid2, CAST(0 AS bigint),S.weight,
		ARRAY[S.playerid1::text],false
	FROM Graph as S
	WHERE S.playerid1 = 'garcifr02'
	UNION ALL
	SELECT S.playerid1,S.playerid2 ,C.weight + length, S.weight, 
		route || (S.playerid1::text),
		S.playerid1 = ANY(route)
	FROM Graph as S, Connected as C
	WHERE S.playerid1 = C.playerid2 AND NOT cycle

),
Valid_People(playerid,yearID,teamid) AS (
	SELECT DISTINCT playerid ,yearID ,teamid FROM(
		(SELECT playerid,yearID,teamid FROM Pitching)
		UNION
		(SELECT playerid,yearID,teamid FROM AllstarFull WHERE GP = 1)
	) AS T
),
Edges(playerid1,playerid2,teamid,yearID) AS (
	SELECT V1.playerid as  playerid1,V2.playerid as playerid2,V1.teamid as teamid,
		V1.yearID as yearID
	FROM Valid_People as V1 
		JOIN Valid_People as V2 ON (V1.teamid = V2.teamid AND V1.yearID = V2.yearID)
	WHERE V1.playerid <> V2.playerid
),
Graph(playerid1,playerid2,weight) AS (
	SELECT playerid1,playerid2,weight 
	FROM
	(
		(
			SELECT playerid1,playerid2, COUNT(*) AS weight
			FROM Edges
			GROUP BY playerid1,playerid2
		)
		UNION
		(
			SELECT playerid2,playerid1, COUNT(*) AS weight
			FROM Edges
			GROUP BY playerid1,playerid2
		)
	) AS T
)

Select MIN(length)
FROM Connected
WHERE playerid2 = 'leagubr01';

--26--

WITH RECURSIVE Connected(teamid1 ,teamid2,length,route,cycle) AS (
	SELECT S.teamid1 ,S.teamid2, CAST(0 AS bigint),
		ARRAY[S.teamid1::text],false
	FROM Graph as S
	WHERE S.teamid1 = 'ARI'
	UNION ALL
	SELECT S.teamid1,S.teamid2 ,1 + length, 
		route || (S.teamid1::text),
		S.teamid1 = ANY(route)
	FROM Graph as S, Connected as C
	WHERE S.teamid1 = C.teamid2 AND NOT cycle

),
Graph(teamid1,teamid2) AS (
	SELECT DISTINCT teamIDwinner as teamid1, teamIDloser as teamid2
	FROM SeriesPost 
)

Select COUNT(*)
FROM Connected
WHERE teamid2 = 'DET';

--27--

WITH RECURSIVE Connected(teamid1 ,teamid2,length,route) AS (
	SELECT S.teamid1 ,S.teamid2, CAST(0 AS bigint),
		ARRAY['dummy':: text || S.teamid1::text]
	FROM Graph as S
	WHERE S.teamid1 = 'HOU'
	UNION ALL
	SELECT S.teamid1,S.teamid2 ,1 + length, 
		route || (C.teamid1::text || C.teamid2::text)
	FROM Graph as S, Connected as C
	WHERE S.teamid1 = C.teamid2 AND NOT ((C.teamid1::text || C.teamid2::text) = ANY(route))  
		AND length<=2

),
Graph(teamid1,teamid2) AS (
	SELECT DISTINCT teamIDwinner as teamid1, teamIDloser as teamid2
	FROM SeriesPost 
)

Select teamid2 as teamid,MAX(length) as num_hops
FROM Connected
WHERE teamid2 <> 'HOU'
GROUP BY teamid2
ORDER BY teamid2 asc;

--28--

WITH RECURSIVE Connected(teamid1 ,teamid2,length,route) AS (
	SELECT S.teamid1 ,S.teamid2, CAST(0 AS bigint),
		ARRAY['dummy':: text || S.teamid1::text]
	FROM Graph as S
	WHERE S.teamid1 = 'HOU'
	UNION ALL
	SELECT S.teamid1,S.teamid2 ,1 + length, 
		route || (C.teamid1::text || C.teamid2::text)
	FROM Graph as S, Connected as C
	WHERE S.teamid1 = C.teamid2 AND NOT ((C.teamid1::text || C.teamid2::text) = ANY(route))

),
Graph(teamid1,teamid2) AS (
	SELECT DISTINCT teamIDwinner as teamid1, teamIDloser as teamid2
	FROM SeriesPost 
),
Child(teamid,length) AS (
	SELECT teamid2 as teamid,length
	FROM Connected
),
Longest(pathlength) AS(
	SELECT MAX(length)
	FROM Connected
	WHERE teamid2 <> 'HOU'
),
Latest(teamid, yearid, lgid ,ranking) AS(
		SELECT teamID as teamid, yearID,lgID,
			rank() OVER (PARTITION BY teamid ORDER BY yearID desc,lgID desc) as ranking
		FROM Teams
),
Latestname(teamid ,teamname) AS (
	SELECT Teams.teamID , name as teamname
	FROM Teams 
	JOIN Latest ON (Latest.teamid = Teams.teamid AND Latest.yearid=Teams.yearID
		AND Latest.lgID = Teams.lgID)
	WHERE ranking = 1
)

SELECT Child.teamID as teamid,teamname,pathlength
FROM Child JOIN Longest ON (Child.length = Longest.pathlength)
	JOIN Latestname ON (Child.teamid = Latestname.teamid)
ORDER BY teamid asc,teamname asc;

--29--

WITH RECURSIVE Connected(teamid1 ,teamid2,length,route) AS (
	SELECT S.teamid1 ,S.teamid2, CAST(0 AS bigint),
		ARRAY['dummy':: text || S.teamid1::text]
	FROM Graph as S
	WHERE S.teamid1 = 'NYA'
	UNION ALL
	SELECT S.teamid1,S.teamid2 ,1 + length, 
		route || (C.teamid1::text || C.teamid2::text)
	FROM Graph as S, Connected as C
	WHERE S.teamid1 = C.teamid2 AND NOT ((C.teamid1::text || C.teamid2::text) = ANY(route))

),
Graph(teamid1,teamid2) AS (
	SELECT DISTINCT teamIDloser as teamid1, teamIDwinner as teamid2
	FROM SeriesPost 
),
Valid_teams(teamid) AS (
	SELECT DISTINCT teamIDwinner
	FROM SeriesPost
	WHERE ties>losses
),
Child(teamid,pathlength) AS (
	SELECT teamid2 as teamid,MIN(length) as pathlength
	FROM Connected
	GROUP by teamid2
)
SELECT Child.teamID as teamid,pathlength
FROM Child JOIN Valid_teams ON (Valid_teams.teamid = Child.teamid)
ORDER BY teamid asc, pathlength asc;
































