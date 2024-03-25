name: Update EPSS database

on:
  workflow_dispatch:
  schedule:
    - cron: '0 0 * * *' # do it every week

jobs:
  update_epss_db:
    if: github.repository_owner == 'EMBA-support-repos'
    runs-on: ubuntu-latest

    steps:
    - name: Checkout Branch
      uses: actions/checkout@v3
    - name: Install requirements
      run: |
        sudo apt-get update -y
    - name: update EPSS db
      run: |
        ./EPSS-crawler.sh
    - name: Create Pull Request
      id: cpr
      uses: peter-evans/create-pull-request@v4
      with:
        token: ${{ secrets.GITHUB_TOKEN }}
        commit-message: Update EPSS database
        committer: GitHub <noreply@github.com>
        author: ${{ github.actor }} <${{ github.actor }}@users.noreply.github.com>
        signoff: false
        branch: epss_update
        delete-branch: true
        title: 'EPSS database update'
        body: |
          Update report
          - Updated latest EPSS data
        labels: |
          db_update
          automated pr
        milestone: 0
        draft: false
