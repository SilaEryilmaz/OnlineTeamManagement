import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:online_team_management/model/Team.dart';
import 'package:online_team_management/model/User.dart';
import 'package:online_team_management/service/auth_service.dart';

class UserService {
  Firestore _firestore = Firestore.instance;

  Future<bool> saveUser(User user) async {
    try {
      await _firestore
          .collection("users")
          .document(user.userId)
          .setData(user.toJson());
      return true;
    } catch (e) {
      print("DEBUG couldn't save $e");
      return false;
    }
  }

  Future<bool> updateUser(User user) async {
    try {
      await Firestore.instance
          .collection('users')
          .document(user.userId)
          .setData(user.toJson());
      return true;
    } catch (e) {
      print("DEBUG: Error UserService updateUser: $e");
      return false;
    }
  }

  Future<User> searchUser(String uid) async {
    try {
      DocumentSnapshot currentUser =
          await _firestore.collection("users").document(uid).get();
      Map<String, dynamic> temp = currentUser.data;
      User user = User.fromJson(temp);
      return user;
    } catch (e) {
      return null;
    }
  }

  Future<List<Team>> getTeams() async {
    try {
      List<Team> foundTeamList = new List();

      List<String> membershipList =
          (await AuthService().currentUser()).membership;

      for (var x in membershipList) {
        DocumentSnapshot currentTeam =
            await _firestore.collection("teams").document(x).get();
        Map<String, dynamic> temp = currentTeam.data;
        Team team = Team.fromJson(temp);
        foundTeamList.add(team);
        return foundTeamList;
      }
    } catch (e) {
      print("DEBUG: Error couldn't get user's tems $e");
      return null;
    }
  }

  Future<List<DocumentSnapshot>> searchUserFromEmail(String searchText) async {
    try {
      List<DocumentSnapshot> documentList = (await Firestore.instance
              .collection("users")
              .where("email", isEqualTo: searchText)
              .getDocuments())
          .documents;

      int length = documentList.length;

      print("DEBUG: length of users $length");

      return documentList;
    } catch (e) {
      return null;
    }
  }
}
