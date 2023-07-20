class ExpenseModel {
  int? amount;
  String? desc;
  String? date;
  String? mode;
  String? to;
  bool? isAddIncome = false;

  ExpenseModel({this.amount, this.desc, this.date, this.mode, this.to});

  ExpenseModel.fromJson(Map<String, dynamic> json) {
    amount = json['amount'];
    desc = json['desc'];
    date = json['date'];
    mode = json['mode'];
    isAddIncome = false;
    to = json['from'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['amount'] = this.amount;
    data['desc'] = this.desc;
    data['date'] = this.date;
    data['isAddIncome'] = false;
    data['mode'] = this.mode;
    data['paidTo'] = this.to;
    return data;
  }
}
