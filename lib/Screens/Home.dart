import 'package:expensetracker/Controllers/API.dart';
import 'package:expensetracker/Controllers/CommonController.dart';
import 'package:expensetracker/Models/ExpenseModel.dart';
import 'package:expensetracker/Models/IncomeModel.dart';
import 'package:expensetracker/Screens/AddTransaction.dart';
import 'package:expensetracker/Screens/CanIBuy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var db = GetStorage();
  bool isDark = false;
  var commonCtrl = Get.put(CommonController());
  bool isLoading = true;

  TrackerAPI api = TrackerAPI();
  List<IncomeModel> listOfIncome = [];
  List<ExpenseModel> listOfExpense = [];

  getIncomeExpense() async {
    listOfIncome = await api.getAllIncome();
    listOfExpense = await api.getAllExpense();
    commonCtrl.expenseList.value = listOfExpense;
    commonCtrl.incomeList.value = listOfIncome;
    commonCtrl.calc();
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    isDark = db.read("theme") ?? false;
    getIncomeExpense();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => Get.changeThemeMode(isDark ? ThemeMode.dark : ThemeMode.light));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        overlayColor: Colors.black,
        overlayOpacity: 0.4,
        children: [
          SpeedDialChild(
              child: const Icon(Icons.arrow_downward),
              label: "Expense",
              onTap: () {
                Get.to(() => const AddTransaction(isIncome: false));
              },
              backgroundColor: Colors.red),
          SpeedDialChild(
              child: const Icon(Icons.arrow_upward),
              label: "Income",
              onTap: () {
                Get.to(() => const AddTransaction(isIncome: true));
              },
              backgroundColor: Colors.green),
        ],
      ),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            setState(() {
              isDark = !isDark;
              Get.changeThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
              db.write("theme", isDark);
            });
          },
          icon: Icon(
            isDark ? Icons.dark_mode : Icons.light_mode,
            color: isDark ? Colors.white : Colors.orange,
          ),
        ),
        actions: [
          IconButton(
              onPressed: () {
                Get.to(() => const CanBuy());
              },
              icon: const Icon(
                Icons.shopping_cart,
              )),
          IconButton(
              onPressed: () {
                setState(() {
                  isLoading = true;
                  getIncomeExpense();
                });
              },
              icon: const Icon(
                Icons.refresh,
              )),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                children: [
                  inPocketWidget(),
                  const SizedBox(
                    height: 20,
                  ),
                  listOfTransactions()
                ],
              ),
            ),
    );
  }

  Widget inPocketWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "In Pocket",
          style: GoogleFonts.dmSans(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        Obx(() => Text(
              "₹ ${commonCtrl.totalInPocket}",
              style:
                  GoogleFonts.dmSans(fontSize: 35, fontWeight: FontWeight.bold),
            )),
        const SizedBox(
          height: 30,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Icon(Icons.arrow_upward),
                ),
                const SizedBox(
                  width: 10,
                ),
                Column(
                  children: [
                    const Text("Income"),
                    Obx(() => Text(
                          "₹${commonCtrl.totalIncome}",
                          style: GoogleFonts.dmSans(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        )),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                Column(
                  children: [
                    const Text("Expense"),
                    Obx(() => Text(
                          "₹${commonCtrl.totalExpense}",
                          style: GoogleFonts.dmSans(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        )),
                  ],
                ),
                const SizedBox(
                  width: 10,
                ),
                const CircleAvatar(
                  backgroundColor: Colors.red,
                  child: Icon(Icons.arrow_downward),
                ),
              ],
            ),
          ],
        )
      ],
    );
  }

  Widget listOfTransactions() {
    return SizedBox(
      height: Get.height,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: commonCtrl.combinesList.length,
        itemBuilder: (context, index) {
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            leading: commonCtrl.combinesList[index].isAddIncome!
                ? const Icon(
                    Icons.arrow_upward,
                    color: Colors.green,
                  )
                : const Icon(
                    Icons.arrow_downward,
                    color: Colors.red,
                  ),
            title: Text(
              "${commonCtrl.combinesList[index].desc}",
              style:
                  GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              "${commonCtrl.combinesList[index].isAddIncome! == false ? commonCtrl.combinesList[index].to : commonCtrl.combinesList[index].from}",
              style:
                  GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "₹${commonCtrl.combinesList[index].amount}",
                  style: GoogleFonts.dmSans(
                      color:
                          commonCtrl.combinesList[index].isAddIncome! == false
                              ? Colors.red
                              : Colors.green,
                      fontSize: 18,
                      fontWeight: FontWeight.w600),
                ),
                Text(
                  DateFormat("dd-MM-yyyy").format(
                      DateTime.parse("${commonCtrl.combinesList[index].date}")
                          .toLocal()),
                  style: GoogleFonts.dmSans(
                      fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
