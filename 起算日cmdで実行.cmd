python -c "
import csv
import datetime
from collections import defaultdict

# CSVファイルを読み込み
rows = []
with open('n:/TaskManaging/カレンダー.csv', 'r', encoding='utf-8') as file:
    reader = csv.reader(file)
    for row in reader:
        rows.append(row)

# ヘッダー行に新しい列を追加
header = rows[0]
header.append('曜日')
header.append('営業日')
header.append('逆算営業日')

# 各月ごとに営業日カウンターを初期化
months_data = defaultdict(list)

# 各行に曜日を追加して、月ごとにデータを分類
for i in range(1, len(rows)):
    row = rows[i]
    date_str = row[0]
    
    # 空行や無効な行をスキップ
    if not date_str or not date_str[0].isdigit():
        continue
    
    # 日付を解析
    date_obj = datetime.datetime.strptime(date_str, '%Y-%m-%d')
    
    # 曜日を追加（日本語表記）
    weekdays = ['月', '火', '水', '木', '金', '土', '日']
    weekday = weekdays[date_obj.weekday()]
    row.append(weekday)
    
    # 営業日フラグを取得
    is_business_day = row[1].upper() == 'TRUE'
    
    # 月ごとにデータを分類
    year_month = (date_obj.year, date_obj.month)
    months_data[year_month].append((date_obj, row, is_business_day))

# 各月ごとに営業日と逆算営業日を計算
for year_month, month_rows in months_data.items():
    # 営業日カウンター（月初から）
    business_day_count = 0
    
    # 各日付に営業日カウントを割り当て
    for date_obj, row, is_business_day in sorted(month_rows, key=lambda x: x[0]):
        if is_business_day:
            business_day_count += 1
            row.append(str(business_day_count))
        else:
            row.append('')
      # 逆算営業日カウンター（月末から）
    reverse_business_days = {}
    business_day_count = 1  # 1起算に変更
    
    # 各日付に逆算営業日カウントを割り当て（月末から逆順に）
    for date_obj, row, is_business_day in sorted(month_rows, key=lambda x: x[0], reverse=True):
        if is_business_day:
            reverse_business_days[date_obj] = business_day_count
            business_day_count += 1
    
    # 逆算営業日を行に追加
    for date_obj, row, is_business_day in sorted(month_rows, key=lambda x: x[0]):
        if is_business_day:
            row.append(str(reverse_business_days[date_obj]))
        else:
            row.append('')

# CSVファイルに書き込み
with open('n:/TaskManaging/カレンダー.csv', 'w', encoding='utf-8', newline='') as file:
    writer = csv.writer(file)
    writer.writerows(rows)

print('カレンダー.csvファイルを更新しました。曜日、営業日、逆算営業日の列を追加しました。')
"