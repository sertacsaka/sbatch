# sbatch
## A PL/SQL package to create modular batch chains with dynamic variable and query support

If you have a working environment where you do not have access to the production database, it can be a nightmare for you to get an error for a batch job. You are expected to detect the error in both the code and the data, if any, and fix it with a ton of manual processes since you cannot immediately deploy to the production environment. Of course, it is in your favor not to make any mistakes during this correction.

Although it is not as troublesome as the example above, it is not a good thing that customer complaints increase due to the inability to immediately deploy to production, for example, a simple business logic or campaign change requested by the sales department. Those working in the call center are also our friends.

I do not claim that the systems adapted through this package will provide a definitive solution to the problems I have mentioned, but I think it will provide flexibility.

####Pros
- Flexibility.
- Need no deployment in most bug cases.
- Quick response to performance problems such as unwanted explain plan changes.
- Immediate business logic changes possible.
- Every structure that comes to mind can be parametricized so that it can be changed from an interface, and most workloads can be transferred to the relevant department.

####Cons
- Loose coupling, or even no coupling. Oracle will not be able to determine the relation between used objects and the batch.
- Some missing grants can only be detected during execution time.
- I'm not sure how system admins would approach using so many dynamic sql or clob values.


### Install Package
First, run "objects.sql" and then compile sbatch package.

### Create demo data and objects
Execute the scripts in "sample script" files in the order below:
- sample_db_data.sql
- sample_query_data.sql
- sample_condition_data.sql
- sample_tag_data.sql



https://user-images.githubusercontent.com/106110139/180446919-b7eb1c43-4a09-4f22-b9cc-5cad579c0d04.mp4

