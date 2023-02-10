BEGIN TRANSACTION;

--
-- Database: Baseball database
--

-- --------------------------------------------------------

--
-- Table structure for table People
--
--

DROP TABLE IF EXISTS People;
CREATE TABLE People (
	playerID varchar(10) DEFAULT NULL,
	birthYear int DEFAULT NULL,
	birthMonth int DEFAULT NULL,
	birthDay int DEFAULT NULL,
	birthCountry varchar(50) DEFAULT NULL,
	birthState varchar(50) DEFAULT NULL,
	birthCity varchar(50) DEFAULT NULL,
	deathYear int DEFAULT NULL,
	deathMonth int DEFAULT NULL,
	deathDay int DEFAULT NULL,
	deathCountry varchar(50) DEFAULT NULL,
	deathState varchar(50) DEFAULT NULL,
	deathCity varchar(50) DEFAULT NULL,
	nameFirst varchar(50) DEFAULT NULL,
	nameLast varchar(50) DEFAULT NULL,
	nameGiven varchar(255) DEFAULT NULL,
	weight int DEFAULT NULL,
	height double precision DEFAULT NULL,
	bats varchar(1) DEFAULT NULL,
	throws varchar(1) DEFAULT NULL,
	debut varchar(10) DEFAULT NULL,
	finalGame varchar(10) DEFAULT NULL,
	retroID varchar(9) DEFAULT NULL,
	bbrefID varchar(9) DEFAULT NULL,
	PRIMARY KEY (playerID)
);

-- --------------------------------------------------------

--
-- Table structure for table TeamsFranchises
--
--

DROP TABLE IF EXISTS TeamsFranchises;
CREATE TABLE TeamsFranchises (
	franchID varchar(3) NOT NULL,
	franchName varchar(50) DEFAULT NULL,
	active varchar(2) DEFAULT NULL,
	NAassoc varchar(3) DEFAULT NULL,
	PRIMARY KEY (franchID)
);

-- --------------------------------------------------------

--
-- Table structure for table Teams
--
--

DROP TABLE IF EXISTS Teams;
CREATE TABLE Teams (
	yearID int NOT NULL,
	lgID varchar(2) NOT NULL,
	teamID varchar(3) NOT NULL,
	franchID varchar(3) DEFAULT NULL,
	divID varchar(1) DEFAULT NULL,
	Rank int DEFAULT NULL,
	G int DEFAULT NULL,
	Ghome int DEFAULT NULL,
	W int DEFAULT NULL,
	L int DEFAULT NULL,
	DivWin boolean DEFAULT NULL, --changed to boolean
	WCWin boolean DEFAULT NULL,  --changed to boolean
	LgWin boolean DEFAULT NULL,  --changed to boolean
	WSWin boolean DEFAULT NULL,  --changed to boolean
	R int DEFAULT NULL,
	AB int DEFAULT NULL,
	H int DEFAULT NULL,
	H2B int DEFAULT NULL,
	H3B int DEFAULT NULL,
	HR int DEFAULT NULL,
	BB int DEFAULT NULL,
	SO int DEFAULT NULL,
	SB int DEFAULT NULL,
	CS int DEFAULT NULL,
	HBP int DEFAULT NULL,
	SF int DEFAULT NULL,
	RA int DEFAULT NULL,
	ER int DEFAULT NULL,
	ERA double precision DEFAULT NULL,
	CG int DEFAULT NULL,
	SHO int DEFAULT NULL,
	SV int DEFAULT NULL,
	IPouts int DEFAULT NULL,
	HA int DEFAULT NULL,
	HRA int DEFAULT NULL,
	BBA int DEFAULT NULL,
	SOA int DEFAULT NULL,
	E int DEFAULT NULL,
	DP int DEFAULT NULL,
	FP double precision DEFAULT NULL,
	name varchar(50) DEFAULT NULL,
	park varchar(255) DEFAULT NULL,
	attendance int DEFAULT NULL,
	BPF int DEFAULT NULL,
	PPF int DEFAULT NULL,
	teamIDBR varchar(3) DEFAULT NULL,
	teamIDlahman45 varchar(3) DEFAULT NULL,
	teamIDretro varchar(3) DEFAULT NULL,
	PRIMARY KEY (yearID,lgID,teamID),
	CONSTRAINT fk_franchID_teams
	FOREIGN KEY(franchID)
	REFERENCES TeamsFranchises(franchID) 
);

-- --------------------------------------------------------

--
-- Table structure for table Batting
--
--

DROP TABLE IF EXISTS Batting;
CREATE TABLE Batting (
	playerID varchar(10) NOT NULL,
	yearID int NOT NULL,
	stint int NOT NULL,
	teamID varchar(3) DEFAULT NULL,
	lgID varchar(2) DEFAULT NULL,
	G int DEFAULT NULL,
	AB int DEFAULT NULL,
	R int DEFAULT NULL,
	H int DEFAULT NULL,
	H2B int DEFAULT NULL,
	H3B int DEFAULT NULL,
	HR int DEFAULT NULL,
	RBI int DEFAULT NULL,
	SB int DEFAULT NULL,
	CS int DEFAULT NULL,
	BB int DEFAULT NULL,
	SO int DEFAULT NULL,
	IBB int DEFAULT NULL,
	HBP int DEFAULT NULL,
	SH int DEFAULT NULL,
	SF int DEFAULT NULL,
	GIDP int DEFAULT NULL,
	PRIMARY KEY (playerID,yearID,stint),
	CONSTRAINT fk_playerID_batting
	FOREIGN KEY(playerID)
	REFERENCES People(playerID),
	CONSTRAINT fk_teamID_batting
	FOREIGN KEY(teamID, yearID, lgID)
	REFERENCES Teams(teamID, yearID, lgID)
	-- CONSTRAINT fk_lgID_batting
	-- FOREIGN KEY(lgID)
	-- REFERENCES Teams(lgID)
);

-- --------------------------------------------------------

--
-- Table structure for table Fielding
--
--

DROP TABLE IF EXISTS Fielding;
CREATE TABLE Fielding (
	playerID varchar(10) NOT NULL,
	yearID int NOT NULL,
	stint int NOT NULL,
	teamID varchar(3) DEFAULT NULL,
	lgID varchar(2) DEFAULT NULL,
	POS varchar(2) NOT NULL,
	G int DEFAULT NULL,
	GS int DEFAULT NULL,
	InnOuts int DEFAULT NULL,
	PO int DEFAULT NULL,
	A int DEFAULT NULL,
	E int DEFAULT NULL,
	DP int DEFAULT NULL,
	PB int DEFAULT NULL,
	WP int DEFAULT NULL,
	SB int DEFAULT NULL,
	CS int DEFAULT NULL,
	ZR double precision DEFAULT NULL,
	PRIMARY KEY (playerID,yearID,stint,POS),
	CONSTRAINT fk_playerID_fielding
	FOREIGN KEY(playerID)
	REFERENCES People(playerID),
	CONSTRAINT fk_teamID_fielding
	FOREIGN KEY(teamID, yearID, lgID)
	REFERENCES Teams(teamID, yearID, lgID)
	-- CONSTRAINT fk_lgID_fielding
	-- FOREIGN KEY(lgID)
	-- REFERENCES Teams(lgID)

);

-- --------------------------------------------------------

--
-- Table structure for table Pitching
--
--

DROP TABLE IF EXISTS Pitching;
CREATE TABLE Pitching (
	playerID varchar(10) NOT NULL,
	yearID int NOT NULL,
	stint int NOT NULL,
	teamID varchar(3) DEFAULT NULL,
	lgID varchar(2) DEFAULT NULL,
	W int DEFAULT NULL,
	L int DEFAULT NULL,
	G int DEFAULT NULL,
	GS int DEFAULT NULL,
	CG int DEFAULT NULL,
	SHO int DEFAULT NULL,
	SV int DEFAULT NULL,
	IPouts int DEFAULT NULL,
	H int DEFAULT NULL,
	ER int DEFAULT NULL,
	HR int DEFAULT NULL,
	BB int DEFAULT NULL,
	SO int DEFAULT NULL,
	BAOpp double precision DEFAULT NULL,
	ERA double precision DEFAULT NULL,
	IBB int DEFAULT NULL,
	WP int DEFAULT NULL,
	HBP int DEFAULT NULL,
	BK int DEFAULT NULL,
	BFP int DEFAULT NULL,
	GF int DEFAULT NULL,
	R int DEFAULT NULL,
	SH int DEFAULT NULL,
	SF int DEFAULT NULL,
	GIDP int DEFAULT NULL,
	PRIMARY KEY (playerID,yearID,stint),
	CONSTRAINT fk_playerID_pitching
	FOREIGN KEY(playerID)
	REFERENCES People(playerID),
	CONSTRAINT fk_teamID_pitching
	FOREIGN KEY(teamID, yearID, lgID)
	REFERENCES Teams(teamID, yearID, lgID)
	-- CONSTRAINT fk_lgID_pitching
	-- FOREIGN KEY(lgID)
	-- REFERENCES Teams(lgID)
);

-- --------------------------------------------------------

--
-- Table structure for table AllstarFull
--
--

DROP TABLE IF EXISTS AllstarFull;
CREATE TABLE AllstarFull (
	playerID varchar(10) NOT NULL,
	yearID int NOT NULL,
	gameNum int NOT NULL,
	gameID varchar(12) DEFAULT NULL,
	teamID varchar(3) DEFAULT NULL,
	lgID varchar(2) DEFAULT NULL,
	GP int DEFAULT NULL,
	startingPos int DEFAULT NULL,
	PRIMARY KEY (playerID,yearID,gameNum),
	CONSTRAINT fk_playerID_allstarfull
	FOREIGN KEY(playerID)
	REFERENCES People(playerID)
	-- CONSTRAINT fk_teamID_allstarfull
	-- FOREIGN KEY(teamID)
	-- REFERENCES Teams(teamID),
	-- CONSTRAINT fk_lgID_allstarfull
	-- FOREIGN KEY(lgID)
	-- REFERENCES Teams(lgID)
);

-- --------------------------------------------------------

--
-- Table structure for table Appearances
--
--

DROP TABLE IF EXISTS Appearances;
CREATE TABLE Appearances (
	yearID int NOT NULL,
	teamID varchar(3) NOT NULL,
	lgID varchar(2) DEFAULT NULL,
	playerID varchar(10) NOT NULL,
	G_all int DEFAULT NULL,
	GS int DEFAULT NULL,
	G_batting int DEFAULT NULL,
	G_defense int DEFAULT NULL,
	G_p int DEFAULT NULL,
	G_c int DEFAULT NULL,
	G_1b int DEFAULT NULL,
	G_2b int DEFAULT NULL,
	G_3b int DEFAULT NULL,
	G_ss int DEFAULT NULL,
	G_lf int DEFAULT NULL,
	G_cf int DEFAULT NULL,
	G_rf int DEFAULT NULL,
	G_of int DEFAULT NULL,
	G_dh int DEFAULT NULL,
	G_ph int DEFAULT NULL,
	G_pr int DEFAULT NULL,
	PRIMARY KEY (yearID,teamID,playerID),
	CONSTRAINT fk_playerID_appearances
	FOREIGN KEY(playerID)
	REFERENCES People(playerID)
	-- CONSTRAINT fk_teamID_appearances
	-- FOREIGN KEY(teamID)
	-- REFERENCES Teams(teamID),
	-- CONSTRAINT fk_lgID_appearances
	-- FOREIGN KEY(lgID)
	-- REFERENCES Teams(lgID)
);

-- --------------------------------------------------------

--
-- Table structure for table AwardsManagers
--
--

DROP TABLE IF EXISTS AwardsManagers;
CREATE TABLE AwardsManagers (
	playerID varchar(10) NOT NULL,
	awardID varchar(25) NOT NULL,
	yearID int NOT NULL,
	lgID varchar(2) NOT NULL,
	tie boolean DEFAULT NULL,  --changed to boolean
	notes varchar(100) DEFAULT NULL,
	PRIMARY KEY (yearID,awardID,lgID,playerID),
	CONSTRAINT fk_playerID_awardsManagers
	FOREIGN KEY(playerID)
	REFERENCES People(playerID)
	-- CONSTRAINT fk_lgID_awardsManagers
	-- FOREIGN KEY(lgID)
	-- REFERENCES Teams(lgID)
);

-- --------------------------------------------------------

--
-- Table structure for table AwardsPlayers
--
--

DROP TABLE IF EXISTS AwardsPlayers;
CREATE TABLE AwardsPlayers (
	playerID varchar(10) NOT NULL,
	awardID varchar(255) NOT NULL,
	yearID int NOT NULL,
	lgID varchar(2) NOT NULL,
	tie boolean DEFAULT NULL,  --changed to boolean
	notes varchar(100) DEFAULT NULL,
	PRIMARY KEY (yearID,awardID,lgID,playerID),
	CONSTRAINT fk_playerID_awardsPlayers
	FOREIGN KEY(playerID)
	REFERENCES People(playerID)
	-- CONSTRAINT fk_lgID_awardsPlayers
	-- FOREIGN KEY(lgID)
	-- REFERENCES Teams(lgID)
);

-- --------------------------------------------------------

--
-- Table structure for table AwardsShareManagers
--
--

DROP TABLE IF EXISTS AwardsShareManagers;
CREATE TABLE AwardsShareManagers (
	awardID varchar(25) NOT NULL,
	yearID int NOT NULL,
	lgID varchar(2) NOT NULL,
	playerID varchar(10) NOT NULL,
	pointsWon int DEFAULT NULL,
	pointsMax int DEFAULT NULL,
	votesFirst int DEFAULT NULL,
	PRIMARY KEY (awardID,yearID,lgID,playerID),
	CONSTRAINT fk_playerID_AwardsShareManagers
	FOREIGN KEY(playerID)
	REFERENCES People(playerID)
	-- CONSTRAINT fk_lgID_AwardsShareManagers
	-- FOREIGN KEY(lgID)
	-- REFERENCES Teams(lgID)
);

-- --------------------------------------------------------

--
-- Table structure for table AwardsSharePlayers
--
--

DROP TABLE IF EXISTS AwardsSharePlayers;
CREATE TABLE AwardsSharePlayers (
	awardID varchar(25) NOT NULL,
	yearID int NOT NULL,
	lgID varchar(2) NOT NULL,
	playerID varchar(10) NOT NULL,
	pointsWon double precision DEFAULT NULL,
	pointsMax int DEFAULT NULL,
	votesFirst double precision DEFAULT NULL,
	PRIMARY KEY (awardID,yearID,lgID,playerID),
	CONSTRAINT fk_playerID_AwardsSharePlayers
	FOREIGN KEY(playerID)
	REFERENCES People(playerID)
	-- CONSTRAINT fk_lgID_AwardsSharePlayers
	-- FOREIGN KEY(lgID)
	-- REFERENCES Teams(lgID)
);

-- --------------------------------------------------------

--
-- Table structure for table HallOfFame
--
--

DROP TABLE IF EXISTS HallOfFame;
CREATE TABLE HallOfFame (
	playerID varchar(10) NOT NULL,
	yearid int NOT NULL,
	votedBy varchar(64) NOT NULL DEFAULT '',
	ballots int DEFAULT NULL,
	needed int DEFAULT NULL,
	votes int DEFAULT NULL,
	inducted boolean DEFAULT NULL,  --changed to boolean
	category varchar(20) DEFAULT NULL,
	needed_note varchar(20) DEFAULT NULL,
	PRIMARY KEY (playerID,yearid,votedBy),
	CONSTRAINT fk_playerID_HallOfFame
	FOREIGN KEY(playerID)
	REFERENCES People(playerID)
);

-- --------------------------------------------------------

--
-- Table structure for table Managers
--
--

DROP TABLE IF EXISTS Managers;
CREATE TABLE Managers (
	playerID varchar(10) DEFAULT NULL,
	yearID int NOT NULL,
	teamID varchar(3) NOT NULL,
	lgID varchar(2) DEFAULT NULL,
	inseason int NOT NULL,
	G int DEFAULT NULL,
	W int DEFAULT NULL,
	L int DEFAULT NULL,
	rank int DEFAULT NULL,
	plyrMgr boolean DEFAULT NULL,  --changed to boolean
	PRIMARY KEY (yearID,teamID,inseason),
	CONSTRAINT fk_playerID_Managers
	FOREIGN KEY(playerID)
	REFERENCES People(playerID)
	-- CONSTRAINT fk_teamID_Managers
	-- FOREIGN KEY(teamID)
	-- REFERENCES Teams(teamID),
	-- CONSTRAINT fk_lgID_Managers
	-- FOREIGN KEY(lgID)
	-- REFERENCES Teams(lgID)
);

-- --------------------------------------------------------

--
-- Table structure for table Salaries
--
--

DROP TABLE IF EXISTS Salaries;
CREATE TABLE Salaries (
	yearID int NOT NULL,
	teamID varchar(3) NOT NULL,
	lgID varchar(2) NOT NULL,
	playerID varchar(10) NOT NULL,
	salary double precision DEFAULT NULL,
	PRIMARY KEY (yearID,teamID,lgID,playerID),
	CONSTRAINT fk_playerID_Salaries
	FOREIGN KEY(playerID)
	REFERENCES People(playerID)
	-- CONSTRAINT fk_teamID_Salaries
	-- FOREIGN KEY(teamID)
	-- REFERENCES Teams(teamID),
	-- CONSTRAINT fk_lgID_Salaries
	-- FOREIGN KEY(lgID)
	-- REFERENCES Teams(lgID)
);

-- --------------------------------------------------------

--
-- Table structure for table Schools
--
--

DROP TABLE IF EXISTS Schools;
CREATE TABLE Schools (
	schoolID varchar(15) NOT NULL,
	schoolName varchar(255) DEFAULT NULL,
	schoolCity varchar(55) DEFAULT NULL,
	schoolState varchar(55) DEFAULT NULL,
	schoolNick varchar(55) DEFAULT NULL,
	PRIMARY KEY (schoolID)
);

-- --------------------------------------------------------

--
-- Table structure for table CollegePlaying
--
--

DROP TABLE IF EXISTS CollegePlaying;
CREATE TABLE CollegePlaying (
	playerID varchar(10) NOT NULL,
	schoolID varchar(15) NOT NULL,
	yearID int NOT NULL,
	PRIMARY KEY (playerID, schoolID, yearID),
	CONSTRAINT fk_playerID_CollegePlaying
	FOREIGN KEY(playerID)
	REFERENCES People(playerID),
	CONSTRAINT fk_schoolID_CollegePlaying
	FOREIGN KEY(schoolID)
	REFERENCES Schools(schoolID)
);

-- --------------------------------------------------------

--
-- Table structure for table SeriesPost
--
--

DROP TABLE IF EXISTS SeriesPost;
CREATE TABLE SeriesPost (
	yearID int NOT NULL,
	round varchar(5) NOT NULL,
	teamIDwinner varchar(3) DEFAULT NULL,
	lgIDwinner varchar(2) DEFAULT NULL,
	teamIDloser varchar(3) DEFAULT NULL,
	lgIDloser varchar(2) DEFAULT NULL,
	wins int DEFAULT NULL,
	losses int DEFAULT NULL,
	ties int DEFAULT NULL,
	PRIMARY KEY (yearID,round)
	-- CONSTRAINT fk_teamIDwinner_SeriesPost
	-- FOREIGN KEY(teamIDwinner)
	-- REFERENCES Teams(teamID),
	-- CONSTRAINT fk_teamIDloser_SeriesPost
	-- FOREIGN KEY	(teamIDloser)
	-- REFERENCES Teams(teamID)
);

-- --------------------------------------------------------


END TRANSACTION;

