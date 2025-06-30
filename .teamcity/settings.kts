import jetbrains.buildServer.configs.kotlin.*
import jetbrains.buildServer.configs.kotlin.buildSteps.script
import jetbrains.buildServer.configs.kotlin.triggers.vcs
import jetbrains.buildServer.configs.kotlin.vcs.GitVcsRoot

/*
The settings script is an entry point for defining a TeamCity
project hierarchy. The script should contain a single call to the
project() function with a Project instance or an init function as
an argument.

VcsRoots, BuildTypes, Templates, and subprojects can be
registered inside the project using the vcsRoot(), buildType(),
template(), and subProject() methods respectively.

To debug settings scripts in command-line, run the

    mvnDebug org.jetbrains.teamcity:teamcity-configs-maven-plugin:generate

command and attach your debugger to the port 8000.

To debug in IntelliJ Idea, open the 'Maven Projects' tool window (View
-> Tool Windows -> Maven Projects), find the generate task node
(Plugins -> teamcity-configs -> teamcity-configs:generate), the
'Debug' option is available in the context menu for the task.
*/

version = "2025.03"

project {

    vcsRoot(HttpsGithubComTorrmundNetologyDevopsDiplomaGit)

    buildType(Apply)
}

object Apply : BuildType({
    name = "Apply"

    artifactRules = "infrastructure/tfplan => plans/"

    params {
        password("env.CLOUD_ID", "zxxf073e708b94452d05e3e40721a7a9e4fb5d33f662468125f")
        password("env.VMS_SSH_PUBLIC_KEY", "zxx6aa924df407532fe32c9e8c359db260504ee7e363bb35d58b2139e2c19666566e56dbc51cf81ccb1a4416ec656d64fc7f62e801e5495dbe70cc3e93da455ed665828ee5afeea5084db3ea7d2993101d0a0db3dbf2ed9419abf8ceb1ac8928b38ebea3fe552eb179e3ee5b5cfb10143fc")
        password("env.POSTGRESQL_USERNAME_VAR", "zxx6d1fe8ddec8c3554fc5e476d94e232a9")
        password("env.POSTGRESQL_PASSWORD_VAR", "zxx6d1fe8ddec8c35548b0a0948d4c2534400a7b8fbca961aae")
        password("env.FOLDER_ID", "zxxe6b336106349ccf143c052b62714980fefabbb96dfe26370")
    }

    vcs {
        root(HttpsGithubComTorrmundNetologyDevopsDiplomaGit)
    }

    steps {
        script {
            name = "Apply"
            id = "Apply"
            scriptContent = """
                #!/bin/bash
                set -e
                cd infrastructure
                source ./setup-env.sh -c %teamcity.agent.home.dir%/secrets/infrastructure_sa_credentials \
                	-k %teamcity.agent.home.dir%/secrets/infrastructure_sa_key.json \
                    -C %env.CLOUD_ID% \
                    -f %env.FOLDER_ID%
                export TF_VAR_vms_ssh_public_key=%env.VMS_SSH_PUBLIC_KEY%
                export TF_VAR_postgresql_username=%env.POSTGRESQL_USERNAME_VAR%
                export TF_VAR_postgresql_password=%env.POSTGRESQL_PASSWORD_VAR%
                terraform init -reconfigure
                terraform plan -out=tfplan -var kube_config=%teamcity.agent.home.dir%/secrets/kube_config
                terraform apply -auto-approve tfplan
            """.trimIndent()
        }
    }

    triggers {
        vcs {
        }
    }
})

object HttpsGithubComTorrmundNetologyDevopsDiplomaGit : GitVcsRoot({
    name = "https://github.com/Torrmund/netology-devops-diploma.git"
    url = "https://github.com/Torrmund/netology-devops-diploma.git"
    branch = "refs/heads/main"
    branchSpec = "+:refs/heads/main"
})
