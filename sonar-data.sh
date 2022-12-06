user=user
password=password
todayDir="$(date +"%d-%m-%Y")"
mkdir -p ./$todayDir
cd ./$todayDir
curl -sk -u ${user}:${password} "https://sonar-url/api/issues/search?componentKeys=com.xyz.project:main&severities=BLOCKER,CRITICAL,MAJOR&statuses=OPEN&tags=sometag&ps=500" > data.json
sed -i 's/\\"//g' data.json
i=0
#cat data.json | jq -c -M '.issues[]' |  while read line; do echo $line > data-$i.json; let "i++"; done
jq -c -r '.issues[] | {key, rule, severity, component, line, message, assignee}' data.json |  \
	while read line; \
	do \
	   echo "$line" > data-$i.json; \
	   cp ../jira-template.json jira-data-$i.json; \
           key=$(jq ".key" data-"$i".json) ; \
	   rule=$(jq ".rule" data-"$i".json) ; \
	   severity=$(jq ".severity" data-"$i".json) ; \
	   component=$(jq ".component" data-"$i".json) ; \
	   linenum=$(jq ".line" data-"$i".json) ; \
	   message=$(jq ".message" data-"$i".json) ; \
	   assignee=$(jq ".assignee" data-"$i".json) ; \
	   notice=`cat ../notice` ; \
	   title="SONAR | $severity violation in $component"; \
           description="Rule $rule violated @ line $linenum.\\nDetails:$message\\n$notice"; \
	   title=`echo "$title" | tr -d \"`
           description=`echo "$description" | tr -d \"`
           assignee=`echo "$assignee" | tr -d \"`
	   #echo "$description" ;\
	   #echo "----" ;\
	   sed -i "s,SUMMARY-TMPL,${title},g" jira-data-$i.json; \
           sed -i "s/ASSIGNEE-TMPL/${assignee}/g" jira-data-$i.json; \
	   sed -i "s/DESC-TMPL/${description}/g" jira-data-$i.json; \
	   let "i++"; \
	done
