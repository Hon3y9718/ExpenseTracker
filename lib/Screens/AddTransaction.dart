import 'package:expensetracker/Controllers/API.dart';
import 'package:expensetracker/Controllers/CommonController.dart';
import 'package:expensetracker/Models/ExpenseModel.dart';
import 'package:expensetracker/Models/IncomeModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AddTransaction extends StatefulWidget {
  final bool isIncome;
  const AddTransaction({super.key, required this.isIncome});

  @override
  State<AddTransaction> createState() => _AddTransactionState();
}

class _AddTransactionState extends State<AddTransaction> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController amount = TextEditingController();
  TextEditingController desc = TextEditingController();
  TextEditingController mode = TextEditingController();
  TextEditingController to = TextEditingController();
  TextEditingController from = TextEditingController();
  TextEditingController date = TextEditingController();

  TrackerAPI api = TrackerAPI();
  var ctrl = Get.put(CommonController());
  var isLoading = false;

  getIncomeExpense() async {
    var listOfIncome = await api.getAllIncome();
    var listOfExpense = await api.getAllExpense();
    ctrl.expenseList.value = listOfExpense;
    ctrl.incomeList.value = listOfIncome;
    ctrl.calc();
    setState(() {
      isLoading = false;
    });
  }

  addIncome() async {
    setState(() {
      isLoading = true;
    });
    IncomeModel incomeModel = IncomeModel(
        amount: int.parse(amount.text),
        date: date.text,
        desc: desc.text,
        from: from.text,
        mode: mode.text);

    api.addIncome(incomeModel, (String response) async {
      print("Response: $response");
      if (response == TrackerAPI.STATUS_SUCCESS) {
        // Feedback is saved succesfully in Google Sheets.
        print("Income Submitted");
        await getIncomeExpense();
        Get.back();
      } else {
        // Error Occurred while saving data in Google Sheets.
        print("Error Occurred!");
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Something went wrong!")));
      }
    });
  }

  addExpense() async {
    setState(() {
      isLoading = true;
    });
    ExpenseModel expenseModel = ExpenseModel(
        amount: int.parse(amount.text),
        date: date.text,
        desc: desc.text,
        to: to.text,
        mode: mode.text);

    api.addExpense(expenseModel, (String response) async {
      print("Response: $response");
      if (response == TrackerAPI.STATUS_SUCCESS) {
        // Feedback is saved succesfully in Google Sheets.
        print("Expense Submitted");
        await getIncomeExpense();
        Get.back();
      } else {
        // Error Occurred while saving data in Google Sheets.
        print("Error Occurred!");
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Something went wrong!")));
      }
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add ${widget.isIncome ? "Income" : "Expense"}",
          style: GoogleFonts.dmSans(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Form(
              key: _formKey,
              child: Container(
                margin: const EdgeInsets.all(15),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      textField(
                          controller: amount,
                          title: "Amount",
                          validation: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Amount is Required';
                            }
                          }),
                      textField(
                          controller: desc,
                          title: "Description",
                          validation: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Description is Required';
                            }
                          }),
                      textField(
                          controller: mode,
                          title: "Mode",
                          validation: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Mode is Required';
                            }
                          }),
                      widget.isIncome
                          ? textField(
                              controller: from,
                              title: "Received From",
                              validation: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Received From is Required';
                                }
                              })
                          : textField(
                              controller: to,
                              title: "Paid To",
                              validation: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Paid To is Required';
                                }
                              }),
                      textField(
                          controller: date,
                          title: "Date",
                          isReadOnly: true,
                          isDate: true,
                          validation: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Date is Required';
                            }
                          }),
                      bigButton(
                          title: "Submit",
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              if (widget.isIncome) {
                                addIncome();
                              } else {
                                addExpense();
                              }
                            }
                          }),
                      const SizedBox(
                        height: 50,
                      )
                    ],
                  ),
                ),
              )),
    );
  }

  Widget bigButton({title, onPressed}) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        height: 55,
        width: Get.width,
        alignment: Alignment.bottomRight,
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              title,
              style:
                  GoogleFonts.dmSans(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(
              width: 10,
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 15,
            )
          ],
        ),
      ),
    );
  }

  Widget textField(
      {controller,
      title,
      isDate = false,
      validation,
      isPassword = false,
      isReadOnly = false}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.dmSans(),
          ),
          const SizedBox(
            height: 10,
          ),
          TextFormField(
              controller: controller,
              obscureText: isPassword,
              keyboardType: title == "Amount" ? TextInputType.number : null,
              onTap: isDate
                  ? () async {
                      DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000, 1, 1),
                          lastDate: DateTime(3000, 1, 1));
                      if (pickedDate != null) {
                        setState(() {
                          date.text = pickedDate.toString();
                        });
                      }
                    }
                  : null,
              readOnly: isReadOnly,
              enableSuggestions: true,
              autocorrect: false,
              decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                filled: true,
                suffixIcon: isPassword
                    ? IconButton(
                        onPressed: () {
                          setState(() {
                            isPassword = !isPassword;
                          });
                        },
                        icon: isPassword
                            ? const Icon(Icons.remove_red_eye)
                            : const Icon(Icons.add))
                    : null,
                hintStyle: TextStyle(color: Colors.grey[800]),
                hintText: "$title",
              ),
              // The validator receives the text that the user has entered.
              validator: validation),
        ],
      ),
    );
  }
}
