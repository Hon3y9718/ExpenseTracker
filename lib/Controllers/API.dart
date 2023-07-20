import 'dart:convert';

import 'package:expensetracker/Models/ExpenseModel.dart';
import 'package:expensetracker/Models/IncomeModel.dart';
import 'package:http/http.dart' as http;

/// FormController is a class which does work of saving FeedbackForm in Google Sheets using
/// HTTP GET request on Google App Script Web URL and parses response and sends result callback.
class TrackerAPI {
  // Google App Script Web URL.
  static const String URL =
      "https://script.google.com/macros/s/AKfycbwMfw3kIvPnYpmNnptkYAohduz7BFmNox4pznAY517eR4UzXh27OMRLgyVQ6OhtUZqL/exec";

  // Success Status Message
  static const STATUS_SUCCESS = "SUCCESS";

  /// Async function which saves feedback, parses [feedbackForm] parameters
  /// and sends HTTP GET request on [URL]. On successful response, [callback] is called.
  void addIncome(
      IncomeModel incomeModel, void Function(String) callback) async {
    try {
      await http
          .post(Uri.parse(URL), body: jsonEncode(incomeModel.toJson()))
          .then((response) async {
        if (response.statusCode == 302) {
          var url = response.headers['location'];
          await http.get(Uri.parse(url!)).then((response) {
            callback(jsonDecode(response.body)['status']);
          });
        } else {
          callback(jsonDecode(response.body)['status']);
        }
      });
    } catch (e) {
      print(e);
    }
  }

  void addExpense(
      ExpenseModel expenseModel, void Function(String) callback) async {
    try {
      await http
          .post(Uri.parse(URL), body: jsonEncode(expenseModel.toJson()))
          .then((response) async {
        if (response.statusCode == 302) {
          var url = response.headers['location'];
          await http.get(Uri.parse(url!)).then((response) {
            callback(jsonDecode(response.body)['status']);
          });
        } else {
          callback(jsonDecode(response.body)['status']);
        }
      });
    } catch (e) {
      print(e);
    }
  }

  getAllIncome() async {
    var resp = await http.post(Uri.parse(URL),
        body: jsonEncode({"getValuesOf": "income"}));

    print("StatusCode: ${resp.statusCode}");
    print("Body: ${resp.body}");

    List<IncomeModel> incomeList = [];

    if (resp.statusCode == 302) {
      var url = resp.headers['location'];
      var res = await http.get(Uri.parse(url!));
      var json = jsonDecode(res.body);
      print(json);
      for (var i = 0; i < json.length; i++) {
        IncomeModel incomeModel = IncomeModel.fromJson(json[i]);
        incomeList.add(incomeModel);
      }
    }
    return incomeList;
  }

  getAllExpense() async {
    var resp = await http.post(Uri.parse(URL),
        body: jsonEncode({"getValuesOf": "expense"}));

    print("StatusCode: ${resp.statusCode}");
    print("Body: ${resp.body}");

    List<ExpenseModel> expenseList = [];

    if (resp.statusCode == 302) {
      var url = resp.headers['location'];
      var res = await http.get(Uri.parse(url!));
      var json = jsonDecode(res.body);
      print(json);
      for (var i = 0; i < json.length; i++) {
        ExpenseModel expenseModel = ExpenseModel.fromJson(json[i]);
        expenseList.add(expenseModel);
      }
    }
    return expenseList;
  }
}
