# Generated by Django 3.1.14 on 2023-10-23 20:08

from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [
        ("core", "0021_auto_20220914_0934"),
    ]

    operations = [
        migrations.AlterField(
            model_name="archiveresult",
            name="extractor",
            field=models.CharField(
                choices=[
                    ("favicon", "favicon"),
                    ("headers", "headers"),
                    ("singlefile", "singlefile"),
                    ("pdf", "pdf"),
                    ("screenshot", "screenshot"),
                    ("dom", "dom"),
                    ("wget", "wget"),
                    ("title", "title"),
                    ("readability", "readability"),
                    ("mercury", "mercury"),
                    ("htmltotext", "htmltotext"),
                    ("git", "git"),
                    ("media", "media"),
                    ("archive_org", "archive_org"),
                ],
                max_length=32,
            ),
        ),
    ]
