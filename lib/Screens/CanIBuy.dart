import 'dart:math';

import 'package:expensetracker/Controllers/CommonController.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

class CanBuy extends StatefulWidget {
  const CanBuy({super.key});

  @override
  State<CanBuy> createState() => _CanBuyState();
}

class _CanBuyState extends State<CanBuy> {
  TextEditingController price = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  var controller = Get.put(CommonController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Can I Buy?",
          style: GoogleFonts.dmSans(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.all(15),
              child: Column(
                children: [
                  textField(
                      title: "Price",
                      ctrl: price,
                      validation: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Price is Required';
                        }
                      }),
                  price.text.isNotEmpty ? result() : Container()
                ],
              ),
            ),
          )),
    );
  }

  var buyIt = ["assets/giphy.gif", "assets/buy-buy-now.gif", "assets/doIt.gif"];

  var noBuy = [
    "assets/captain-nick-nah-nah-nah.gif",
    "assets/nah-nevermind.gif"
  ];

  Widget result() {
    return Column(
      children: [
        const SizedBox(
          height: 20,
        ),
        controller.canIBuyThis.value
            ? Image.asset(buyIt[Random().nextInt(buyIt.length)])
            : Image.asset(noBuy[Random().nextInt(noBuy.length)]),
        const SizedBox(
          height: 20,
        ),
        Text(
          controller.canIBuyThis.value
              ? "Yup, Buy it Bro!"
              : "Nah Bro! Earn More!",
          style: GoogleFonts.dmSans(
              fontSize: 30,
              color: controller.canIBuyThis.value ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold),
        )
      ],
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
      {ctrl, title, validation, isPassword = false, isReadOnly = false}) {
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
              onChanged: (String val) {
                setState(() {
                  if (val.isNotEmpty) {
                    controller.canIBuy(price: int.parse(val));
                  }
                });
              },
              keyboardType: TextInputType.number,
              controller: ctrl,
              obscureText: isPassword,
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
