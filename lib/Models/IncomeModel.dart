class IncomeModel {
  int? amount;
  String? desc;
  String? date;
  String? mode;
  String? from;
  bool? isAddIncome = true;

  IncomeModel({this.amount, this.desc, this.date, this.mode, this.from});

  IncomeModel.fromJson(Map<String, dynamic> json) {
    amount = json['amount'];
    desc = json['desc'];
    isAddIncome = true;
    date = json['date'];
    mode = json['mode'];
    from = json['from'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['amount'] = this.amount;
    data['desc'] = this.desc;
    data['date'] = this.date;
    data['isAddIncome'] = true;
    data['mode'] = this.mode;
    data['from'] = this.from;
    return data;
  }
}
