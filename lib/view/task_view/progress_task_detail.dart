import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:online_team_management/controller/task_controller.dart';
import 'package:online_team_management/model/Task.dart';
import 'package:online_team_management/model/User.dart';
import 'package:online_team_management/util/extension.dart';
import 'package:online_team_management/view/task_view/widget/task_card.dart';
import 'package:online_team_management/view/team_view/widget/user_card.dart';
import 'package:online_team_management/widget/loading_view.dart';
import 'package:provider/provider.dart';

class ProgressTaskDetail extends StatefulWidget {
  Task task;
  ProgressTaskDetail({@required this.task});

  @override
  _ProgressTaskDetailState createState() => _ProgressTaskDetailState();
}

class _ProgressTaskDetailState extends State<ProgressTaskDetail> {
  Widget _floatingActionButton(context) {
    return FutureBuilder(
      future: Provider.of<TaskController>(context, listen: false)
          .isTaskBelongCurrentUser(widget.task),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData && snapshot.data && !widget.task.isDone) {
            return FloatingActionButton.extended(
                backgroundColor: Color(0xFF74CCA2),
                onPressed: () async {
                  widget.task.isDone = true;
                  await Provider.of<TaskController>(context, listen: false)
                      .checkCompletedTask(widget.task);
                  setState(() {});
                },
                label: Text("Check Task"));
          }
        }
        return SizedBox.shrink();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: context.themeData.primaryColorLight,
        floatingActionButton: _floatingActionButton(context),
        appBar: AppBar(
          elevation: 0,
          centerTitle: false,
          title: Text(
            "Task Detail",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: context.themeData.primaryColorDark,
                fontSize: context.dynamicWidth(0.05)),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 22,
              child: Hero(
                tag: "${widget.task.taskId}",
                child: Material(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: context.dynamicHeight(0.18),
                        maxWidth: context.dynamicWidth(0.8),
                      ),
                      child: TaskCard(
                        colors: [
                          Color(0xFF74CCA2),
                          Color(0xFF74CCA2),
                          Color(0xFF9EE8D1),
                        ],
                        task: widget.task,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Spacer(flex: 2),
            Expanded(
              flex: 4,
              child: Padding(
                padding: EdgeInsets.only(
                  left: context.dynamicWidth(0.05),
                ),
                child: FittedBox(
                  child: Text("- Who are doing this task?",
                      style:
                          TextStyle(color: context.themeData.primaryColorDark)),
                ),
              ),
            ),
            Spacer(flex: 2),
            Expanded(
              flex: 65,
              child: FutureBuilder<List<User>>(
                  future: Provider.of<TaskController>(context, listen: false)
                      .getTaskMembers(widget.task),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasData) {
                        List<User> users = snapshot.data;
                        return ListView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            User user = users[index];
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                  height: 50,
                                  width: context.dynamicWidth(0.6),
                                  child: userCard(
                                      context,
                                      "${user.firstName} ${user.lastName}",
                                      "${user.email}")),
                            );
                          },
                        );
                      }
                      return SizedBox.shrink();
                    }
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }),
            ),
          ],
        ));
  }

  Widget userCard(BuildContext context, String name, String email) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                blurRadius: 4,
                spreadRadius: 0.2,
              ),
            ],
            gradient: LinearGradient(
              begin: Alignment.bottomRight,
              end: Alignment.topLeft,
              colors: [
                context.themeData.primaryColorLight,
                context.themeData.primaryColor,
                context.themeData.primaryColor,
                context.themeData.primaryColor,
              ],
            ),
          ),
          child: Row(
            children: [
              Spacer(flex: 5),
              Expanded(
                flex: 10,
                child: Icon(Icons.person,
                    color: context.themeData.primaryColorDark),
              ),
              Spacer(
                flex: 8,
              ),
              Expanded(
                  flex: 67,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FittedBox(
                        child: Text(name,
                            style: TextStyle(
                                color: context.themeData.primaryColorDark,
                                fontWeight: FontWeight.w600)),
                      ),
                      FittedBox(
                        child: Text(email,
                            style: TextStyle(
                                color: context.themeData.primaryColorDark)),
                      ),
                    ],
                  )),
              Spacer(flex: 10),
            ],
          )),
    );
  }
}
