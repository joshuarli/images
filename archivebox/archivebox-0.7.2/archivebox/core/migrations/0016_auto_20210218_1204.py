# Generated by Django 3.1.3 on 2021-02-18 12:04

from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [
        ("core", "0015_auto_20210218_0730"),
    ]

    operations = [
        migrations.AlterField(
            model_name="snapshot",
            name="tags",
            field=models.ManyToManyField(blank=True, to="core.Tag"),
        ),
    ]
