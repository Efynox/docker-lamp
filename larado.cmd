@ECHO OFF

::: Variables initialization ___________
SET _apath=%CD%
SET _apath=%_apath:C:=/c%
SET _apath=%_apath:\=/%
SET args=
SET _hpath=
SET _cpath=
SET _fpath=
SET _mount=--mount type=bind,src=%_apath%,dst=/app
SET _network=--network larado-net

FOR %%I in (.) do SET _dirName=%%~nxI
SET _dockerMysql=larado-mysql-%_dirName%

::: Options parsing
:parse
IF "%1" EQU "-m" GOTO :parseMount

::: Command selection __________________
:cmd
IF "%1" EQU "new" GOTO :cmdNew
IF "%1" EQU "composer" GOTO :cmdComposer
IF "%1" EQU "artisan" GOTO :cmdArtisan
IF "%1" EQU "serve" GOTO :cmdServe
IF "%1" EQU "migrate" GOTO :cmdMigrate
IF "%1" EQU "stop" GOTO :cmdStop
IF "%1" EQU "clean" GOTO :cmdClean
IF "%1" EQU "recreate" GOTO :cmdRecreate
IF "%1" EQU "infos" GOTO :cmdInfos
ECHO -- Unknown or missing action
GOTO :end

:parseMount
	SHIFT
	IF [%1] NEQ [] CALL SET _hpath=%1
	IF [%2] NEQ [] CALL SET _cpath=%2
	CALL SET _fpath=%_hpath%%_cpath%
	IF [%_fpath%] NEQ [] CALL SET _mount=%_mount% --mount type=bind,src=%_hpath%,dst=%_cpath%
	::ECHO Mount option : %_mount%
	
	ECHO Mount %_apath% to /app
	IF [%_fpath%] NEQ [] ECHO Mount %_hpath% to %_cpath%

	SHIFT
	SHIFT
	GOTO :parse

::: New Project _______________________
:cmdNew
	IF [%2] EQU [] GOTO :cmdNew_Err
	ECHO larado : Creating new project "%2
	docker run --rm -i -t %_mount% composer create-project --prefer-dist laravel/laravel %2
	GOTO :end

:cmdNew_Err
	ECHO -- Missing project name
	GOTO :end

::: Composer __________________________
:cmdComposer
	IF DEFINED %1 THEN (
    	SET args=%args% %2
    	SHIFT
    	GOTO :cmdComposer
	) ELSE (
		ECHO larado : composer %args%
		docker run --rm -i -t %_mount% composer %args%
	)
	GOTO :end

::: Artisan ___________________________
:cmdArtisan
	IF DEFINED %1 THEN (
    	SET args=%args% %2
    	SHIFT
    	GOTO :cmdArtisan
	) ELSE (
		ECHO larado : artisan %args%
		docker run --rm -i -t %_mount% %_network% efynox/laravel-artisan %args%
	)
	GOTO :end

::: Serve _____________________________
:cmdServe
	ECHO -- Network : Creating 
	docker network create larado-net

	CALL :mysqlStart

	CALL :serverStart

	ECHO -- -- -- -- -- -- -- -- -- -- 
	ECHO | SET /p="Host ready at : "
	docker-machine ip
	GOTO :end
	
::: Migrate ___________________________
:cmdMigrate
	CALL :mysqlMigrate
	GOTO :end

::: Stop ______________________________
:cmdStop
	ECHO larado : stop
	CALL :serverStop
	CALL :mysqlStop
	GOTO :end

::: Clean _____________________________
:cmdClean
	ECHO larado : clean
	CALL :serverClean
	CALL :mysqlClean
	GOTO :end

::: Recreate __________________________
:cmdRecreate
	ECHO larado : recreate
	CALL :serverStop
	CALL :serverClean

	CALL :mysqlStop
	CALL :mysqlClean

	CALL :mysqlStart
	CALL :serverStart
	GOTO :end

::: Infos _____________________________
:cmdInfos
	ECHO larado : infos
	docker run --rm -i -t --entrypoint=php efynox/laravel-artisan -i
	GOTO :end


:: __MYSQL___BEG________________________
:mysqlStart
	ECHO -- MySQL : Checking container status
	((docker ps --filter "label=larado.mysql" --format "{{.ID}}") && (docker inspect %_dockerMysql% | find "running")) || CALL :mysqlStop
	(docker inspect %_dockerMysql% > NUL) || GOTO :mysqlCreate
	(docker inspect %_dockerMysql% | find "running") || GOTO :mysqlRestart
	(docker inspect %_dockerMysql% | find "running") && ECHO MySQL is already running
	GOTO :end

:mysqlRestart
	ECHO -- MySQL : Restarting container
	docker start %_dockerMysql%
	GOTO :end

:mysqlCreate
	ECHO -- MySQL : Creating container
	docker run -i -t -d --name %_dockerMysql% -e "MYSQL_DATABASE=laravel" -e "MYSQL_USER=laravel" -e "MYSQL_PASSWORD=test" -e "MYSQL_RANDOM_ROOT_PASSWORD=yes" %_network% --network-alias db -p 3306:3306 --label "larado.mysql=yes" mysql

	ECHO -- MySQL : Waiting container to be ready
	:mysqlCreate_Ready
	(docker logs %_dockerMysql% | find "ready" | find "3306") && GOTO :mysqlCreate_Migrate
	ECHO | SET /p="."
	GOTO :mysqlCreate_Ready

	:mysqlCreate_Migrate
	CALL :mysqlMigrate
	CALL :mysqlSeed
	GOTO :end

:mysqlMigrate
	ECHO -- MySQL : Running migrations
	docker run --rm -i -t %_mount% %_network% efynox/laravel-artisan migrate
	GOTO :end

:mysqlSeed
	ECHO -- MySQL : Seeding database
	docker run --rm -i -t %_mount% %_network% efynox/laravel-artisan db:seed
	GOTO :end

:mysqlStop
	ECHO -- MySQL : Stopping current container
	for /f eol^= %%A in ('docker ps --filter "label=larado.mysql" --format "{{.ID}}"') do docker stop %%A
	::docker stop %_dockerMysql%
	GOTO :end

:mysqlClean
	ECHO -- MySQL : Cleaning container
	docker rm %_dockerMysql%
	GOTO :end
:: __MYSQL___END________________________

:: __SERVER__BEG________________________
:serverStart
	ECHO -- Server : Checking container status
	(docker inspect larado-server | find "running") && CALL :serverStop
	(docker inspect larado-server | find "exited") && CALL :serverClean

	CALL :serverCreate

	CALL :serverCron
	
	ECHO -- Server : Starting logs
	docker logs larado-server
	GOTO :end
	
:serverStop
	ECHO -- Server : Stopping current container
	docker stop larado-server
	GOTO :end

:serverClean
	ECHO -- Server : Cleaning container
	docker rm larado-server
	GOTO :end

:serverCreate
	ECHO -- Server : Creating container
	docker run -i -t -d --name larado-server -p 8000:8000 %_mount% %_network%  efynox/laravel-artisan serve --host=0.0.0.0 --port=8000
	GOTO :end

:serverCron
	ECHO -- Server : Adding cron tasks
	docker exec larado-server bash /root/create-cron.sh
	GOTO :end
:: __SERVER__END________________________

:end