# Generated by Django 3.1.8 on 2021-04-10 10:31

from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [
        ("core", "0019_auto_20210401_0654"),
    ]

    operations = [
        migrations.AlterField(
            model_name="archiveresult",
            name="id",
            field=models.AutoField(primary_key=True, serialize=False, verbose_name="ID"),
        ),
        migrations.AlterField(
            model_name="tag",
            name="id",
            field=models.AutoField(primary_key=True, serialize=False, verbose_name="ID"),
        ),
    ]
