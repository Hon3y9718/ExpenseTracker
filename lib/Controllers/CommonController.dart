import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class CommonController extends GetxController {
  Rx<DateTime> selectedDate = DateTime.now().obs;
  RxInt totalInPocket = 0.obs;
  RxInt totalIncome = 0.obs;
  RxInt totalExpense = 0.obs;
  RxList combinesList = [].obs;
  var db = GetStorage();
  RxList incomeList = [].obs;
  RxList expenseList = [].obs;
  RxBool canIBuyThis = false.obs;

  calc() {
    getTotal();
    combineTransactions();
  }

  combineTransactions() {
    combinesList.clear();
    combinesList.value = List.from(incomeList)..addAll(expenseList);
    combinesList.sort((a, b) {
      var adate = DateTime.parse(a.date); //before -> var adate = a.expiry;
      var bdate = DateTime.parse(b.date); //before -> var bdate = b.expiry;
      return adate.compareTo(bdate);
    });
  }

  canIBuy({price = 0}) {
    if (price <= totalInPocket.value) {
      canIBuyThis.value = true;
      return true;
    }
    canIBuyThis.value = false;
    return false;
  }

  getTotal() {
    totalExpense.value = 0;
    totalIncome.value = 0;
    for (var i = 0; i < incomeList.length; i++) {
      totalIncome = totalIncome + incomeList[i].amount!;
    }
    for (var i = 0; i < expenseList.length; i++) {
      totalExpense = totalExpense + expenseList[i].amount!;
    }
    totalInPocket.value = totalIncome.value - totalExpense.value;
  }
}
