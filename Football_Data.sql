# cleaning data #

Update Match 
Set date = Replace(date, '00:00:00', '');

# Altering, adding columns like "Result", "Score" and updating them

Alter table Match
Add column result text;

Update Match
Set Result = '1'
Where home_team_goal > away_team_goal;

Update Match
Set Result = '0'
Where home_team_goal = away_team_goal;

Update Match
Set Result = '2'
Where home_team_goal < away_team_goal;

Alter table Match
Add column Score text;

Update Match
Set Score = home_team_goal || ' - ' || away_team_goal

# Joining tables

SELECT m.date, t.team_long_name AS Home_Team_Name, a.team_long_name AS Away_Team_Name, m.home_team_goal, m.away_team_goal, m.result, m.Score
FROM Match m
JOIN Team t
ON m.home_team_api_id = t.team_api_id
Join Team a
ON m.away_team_api_id = a.team_api_id
LIMIT 10;

Select Result, Count(Result)
From Match
Group By Result;

# Scores

Select Distinct Score
From Match;

Select Distinct Score, Count(Score)
From Match
Group by Score
Order by Count(Score) DESC;

SELECT m.date, t.team_long_name AS Home_Team_Name, a.team_long_name AS Away_Team_Name, m.home_team_goal, m.away_team_goal, m.result, m.Score
FROM Match m
JOIN Team t
ON m.home_team_api_id = t.team_api_id
Join Team a
ON m.away_team_api_id = a.team_api_id
Group by m.Score
Having Count(Score) = 1;

# Looking for big upsets

SELECT m.date, t.team_long_name AS Home_Team_Name, a.team_long_name AS Away_Team_Name, m.result, m.Score, m.B365H, m.B365D, m.B365A
FROM Match m
JOIN Team t
ON m.home_team_api_id = t.team_api_id
Join Team a
ON m.away_team_api_id = a.team_api_id
Where m.B365H >= 15 AND m.result = 1 OR m.B365A >=15 AND m.result = 2;

# Goals overall (in one year in certain leagues, we lack data for Belgium Jupiler League so I excluded it)

Select m.season, m.country_id, Sum(m.home_team_goal + m.away_team_goal) AS Goals_Total, l.name
FROM Match m
Join League l
ON m.country_id = l.country_id
Where l.name NOT LIKE 'Belgium Jupiler League'
Group by m.season, l.name
Order by l.name;

# Wisła Kraków performance

Create Table Wisła_Kraków As
SELECT m.date, m.season, m.home_team_api_id, t.team_long_name AS Home_Team_Name, m.away_team_api_id, a.team_long_name AS Away_Team_Name, m.home_team_goal, m.away_team_goal, m.result, m.Score
FROM Match m
JOIN Team t
ON m.home_team_api_id = t.team_api_id
Join Team a
ON m.away_team_api_id = a.team_api_id
Where Home_Team_Name = 'Wisła Kraków' OR Away_Team_Name = 'Wisła Kraków'
Order by m.date;

Alter table Wisła_Kraków
Add column Points Numeric;

Update Wisła_Kraków
Set Points = '3'
Where home_team_goal > away_team_goal AND Home_Team_Name = 'Wisła Kraków';

Update Wisła_Kraków
Set Points = '3'
Where home_team_goal < away_team_goal AND Away_Team_Name = 'Wisła Kraków';

Update Wisła_Kraków
Set Points = '1'
Where home_team_goal = away_team_goal;

Update Wisła_Kraków
Set Points = '0'
Where home_team_goal < away_team_goal AND Home_Team_Name = 'Wisła Kraków';

Update Wisła_Kraków
Set Points = '0'
Where home_team_goal > away_team_goal AND Away_Team_Name = 'Wisła Kraków';

# Biggest wins, losses

Select date, Home_Team_Name, Away_Team_Name, Score, MAX(home_team_goal - away_team_goal) AS Diff
FROM Wisła_Kraków
UNION
Select date, Home_Team_Name, Away_Team_Name, Score, MIN(home_team_goal - away_team_goal) AS Diff
FROM Wisła_Kraków
UNION
Select date, Home_Team_Name, Away_Team_Name, Score, MAX(home_team_goal - away_team_goal) AS Diff
FROM Wisła_Kraków
WHERE Home_Team_Name <> 'Wisła Kraków'
UNION
Select date, Home_Team_Name, Away_Team_Name, Score, MIN(home_team_goal - away_team_goal) As Diff
FROM Wisła_Kraków
WHERE Away_Team_Name <> 'Wisła Kraków'

Select season, points, COUNT(points)
FROM Wisła_Kraków
Group by season, points
HAVING points = 3
ORDER BY COUNT(Points) DESC

Select Points, Count(Points)
From Wisła_Kraków
Group By Points;

Select season, SUM(Points)
From Wisła_Kraków
Group by season;
