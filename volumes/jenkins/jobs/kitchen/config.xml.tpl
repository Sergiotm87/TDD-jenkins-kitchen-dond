<?xml version='1.1' encoding='UTF-8'?>
<project>
  <actions/>
  <description></description>
  <keepDependencies>false</keepDependencies>
  <properties/>
  <scm class="hudson.scm.NullSCM"/>
  <canRoam>true</canRoam>
  <disabled>false</disabled>
  <blockBuildWhenDownstreamBuilding>false</blockBuildWhenDownstreamBuilding>
  <blockBuildWhenUpstreamBuilding>false</blockBuildWhenUpstreamBuilding>
  <triggers/>
  <concurrentBuild>false</concurrentBuild>
  <builders>
    <hudson.tasks.Shell>
      <command>cd /opt/projects/{{ project_name }}
# Disable exit on non 0
#set +e
#Do something. If something fails with exit!=0 the script continues anyway
# Enable exit on non 0
#set -e
# Do something. If something fails with exit!=0 the script stops
sudo bundle install --path /var/lib/gems/2.3.0/cache
#delete docker image and container if test fails
sudo kitchen test || docker rm -f $(docker ps -lq) &amp;&amp; docker rmi $(docker images | awk NR==2&apos;{print $3}&apos;) &amp;&amp; exit 1</command>
    </hudson.tasks.Shell>
  </builders>
  <publishers>
    <hudson.plugins.postbuildtask.PostbuildTask plugin="postbuild-task@1.8">
      <tasks>
        <hudson.plugins.postbuildtask.TaskProperties>
          <logTexts>
            <hudson.plugins.postbuildtask.LogProperties>
              <logText>Kitchen is finished</logText>
              <operator>AND</operator>
            </hudson.plugins.postbuildtask.LogProperties>
          </logTexts>
          <EscalateStatus>false</EscalateStatus>
          <RunIfJobSuccessful>false</RunIfJobSuccessful>
          <script>#!/bin/bash&#xd;
#tag image if build is ok&#xd;
docker tag $(docker images | awk NR==2&apos;{print $3}&apos;) kammin/{{ project_name }}:latest</script>
        </hudson.plugins.postbuildtask.TaskProperties>
      </tasks>
    </hudson.plugins.postbuildtask.PostbuildTask>
  </publishers>
  <buildWrappers>
    <hudson.plugins.ansicolor.AnsiColorBuildWrapper plugin="ansicolor@0.5.2">
      <colorMapName>xterm</colorMapName>
    </hudson.plugins.ansicolor.AnsiColorBuildWrapper>
  </buildWrappers>
</project>
