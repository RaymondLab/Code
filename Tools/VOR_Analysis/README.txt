================================================================================
VOR_Analysis is a helpful GUI that is used to analyze VOR Experimental Data

For any questions regarding this code, please contact Maxwell Gagnon:
  max [dot] gagnon11 [at] gmail [dot] com
  maxwellg [at] Stanford [dot] edu

Last updated README - July 31, 2018

================================================================================
CONTENTS
================================================================================
  - Pipeline or flow of VOR_Analysis
    - TODO
  - List of Files and their use
    - TODO
  - Setting up Source-Tree & repository
  - Other Tips and Tricks
    - TODO



================================================================================
PIPELINE OR FLOW OF VOR_ANALYSIS
================================================================================

VOR_Analysis
    - GUI
    - User inputs their desired Parameters, then clicks 'run'
    - VOR_Analysis sends takes that information and builds the 'params' structure
      and sends it to runTest

VOR_Tests
  - 'backbone' of scripts
  - Two main jobs
    1) Run specific analysis(s)
    2) Make subplot of all figures created in the analysis(s)

VOR_Default
  -

VOR_SineFit
  - 
================================================================================
LIST OF FILES AND THEIR USE
================================================================================
================================================================================
SETTING UP SOURCETREE & REPOSITORY
================================================================================
  0) Pre Set Up
    - Make sure that you have access to the lab's server.
    - NOTE: If you plan on making changes/additions of ANY kind to the code, I
      HIGHLY suggest finding tutorials for:
        - Version Control
        - GIT: The most common type of Version Control
        - Source-Tree: And interface for GIT
    - They are not difficult to use, but here is too much information about
      them to cover in this README.

  1) Download Source-Tree
    - https://www.sourcetreeapp.com/
  2) Make an Atlassian Account
    - It is best to use your Stanford email when making an account

  ~~ For Windows ~~
  3) Cloning a copy of the Repository to your computer
    - 'File' --> 'Clone / New...'
    - For the 'Source Path / URL:' Window
      - Enter the file location of the repo. As of July 31, 2018, it is located:
                        Z:\3_Code\Raymond_Lab_Code_Repo
      - NOTE: Here, the server is mapped to drive 'Z'. This may be different on
        your machine!! It might be easier to click the 'browse' button in Source
        Tree and locate that folder manually.
    - Choose a location on your machine to place the repo.
    - Choose a name for your local copy of the repo.
    - Click 'Clone'

  ~~ For Mac ~~
  3) TODO

  ~~ For Linux ~~
  3) TODO

  ~~ All ~~
  4) Check to see that it worked
    - Navigate to the 'Working Copy' section listed on the top-ish left. It is
      listed under 'FILE STATUS'
    - Click on 'Log / History' near the bottom. If there is a long list of commits,
      then the set up was correct. You can access your local copy of the repo
      from wherever you placed it in your machine.

================================================================================
OTHER TIPS AND TRICKS
================================================================================
  - To edit the GUI, use the 'guide' command in MATLAB





































...
