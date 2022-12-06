from jira import JIRA

jira = JIRA(
    basic_auth=("user", "password"),
    options={
      'server':'https://jira-server'
    }
)  # a username/password tuple
