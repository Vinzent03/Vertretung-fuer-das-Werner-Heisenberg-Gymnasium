import 'package:Vertretung/data/names.dart';
import 'package:Vertretung/logic/shared_pref.dart';
import 'package:Vertretung/provider/theme_settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ThemeModeSelection extends StatelessWidget {
  final ThemeMode selectedThemeMode;
  ThemeModeSelection(this.selectedThemeMode);

  final List<String> modes = ["System", "Heller Modus", "Dunkler Modus"];

  showSelection(context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15))),
        title: Text("Wähle den Modus."),
        content: Container(
          width: 50,
          child: ListView.builder(
            itemCount: modes.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return TextButton(
                onPressed: () {
                  SharedPref.setInt(Names.themeMode, index);
                  context
                      .read<ThemeSettings>()
                      .setThemeMode(ThemeMode.values[index]);
                  Navigator.pop(context);
                },
                child: Text(
                  modes[index],
                  style: TextStyle(fontSize: 17),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.color_lens),
      title: Text("Theme"),
      trailing: TextButton(
        child: Text(modes[selectedThemeMode.index]),
        onPressed: () => showSelection(context),
      ),
      onTap: () => showSelection(context),
    );
  }
}