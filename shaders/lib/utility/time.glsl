#ifndef _TIME_GLSL
#define _TIME_GLSL 1

#include "/lib/settings.glsl"

uniform ivec3 currentDate;
uniform ivec3 currentTime;
uniform ivec2 currentYearTime;

#define UTC(hour, minute) ((hour < 0 ? -1 : 1) * (abs(hour) * 3600 + minute * 60))

const int UTC_OFFSETS[] = int[](
    UTC(-12, 0), UTC(-11, 0), UTC(-10, 0), UTC(-9, 30),
    UTC(-9, 0),  UTC(-8, 0),  UTC(-7, 0),  UTC(-6, 0),
    UTC(-5, 0),  UTC(-4, 0),  UTC(-3, 30), UTC(-3, 0),
    UTC(-2, 0),  UTC(-1, 0),  UTC(+0, 0),  UTC(+1, 0),
    UTC(+2, 0),  UTC(+3, 0),  UTC(+3, 30), UTC(+4, 0),
    UTC(+4, 30), UTC(+5, 0),  UTC(+5, 30), UTC(+5, 45),
    UTC(+6, 0),  UTC(+6, 30), UTC(+7, 0),  UTC(+8, 0),
    UTC(+8, 45), UTC(+9, 0),  UTC(+9, 30), UTC(+10, 0),
    UTC(+10, 30), UTC(+11, 0), UTC(+12, 0), UTC(+12, 45),
    UTC(+13, 0),  UTC(+14, 0)
);

struct datetime {
    int year;
    int month;
    int day;
    int hour;
    int minute;
    int second;
};

uint datetimeToUnix(datetime dt) {
    dt.year -= int(dt.month <= 2);
    int era = (dt.year >= 0 ? dt.year : dt.year - 399) / 400;
    uint yoe = uint(dt.year - era * 400);
    uint doy = uint((153 * (dt.month + (dt.month > 2 ? -3 : 9)) + 2) / 5 + dt.day - 1);
    uint doe = yoe * 365u + yoe / 4u - yoe / 100u + doy;
    uint days = era * 146097u + doe - 719468u;
    return days * 86400u + uint(dt.hour) * 3600u + uint(dt.minute) * 60u + uint(dt.second);
}

datetime unixToDatetime(uint unix) {
    datetime dt;

    dt.second = int(unix % 60u);
    unix /= 60u;
    dt.minute = int(unix % 60u);
    unix /= 60u;
    dt.hour = int(unix % 24u);
    unix /= 24u;

    uint z = unix + 719468u;
    uint era = z / 146097u;
    uint doe = z - era * 146097u;
    uint yoe = (doe - doe / 1460u + doe / 36524u - doe / 146096u) / 365u;
    uint y = yoe + era * 400u;
    uint doy = doe - (yoe * 365u + yoe / 4u - yoe / 100u);
    uint mp = (doy * 5u + 2u) / 153u;

    dt.day = int(doy - (mp * 153u + 2u) / 5u + 1u);
    dt.month = int(mp) + (mp < 10u ? 3 : -9);
    dt.year = int(y) + int(dt.month <= 2);

    return dt;
}

int getLeapYears(int year) {
    year--;
    return year / 4 - year / 100 + year / 400;
}

bool isLeapYear(int year) {
    return ((year % 100) != 0 && (year % 4) == 0) || ((year % 100) == 0 && (year % 400) == 0);
}

int daysInMonth(int month) {
    const int[] nDays = int[](31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
    return nDays[month - 1];
}

int daysInMonth(int month, int year) {
    return daysInMonth(month) + int(month == 2 && isLeapYear(year));
}

datetime currentLocalTime() {
    return datetime(currentDate.x, currentDate.y, currentDate.z, currentTime.x, currentTime.y, currentTime.z);
}

datetime convertToUniversalTime(datetime dt) {
    int tzOffset = UTC_OFFSETS[TIME_ZONE];
    return unixToDatetime(datetimeToUnix(dt) - tzOffset);
}

datetime currentUniversalTime() {
    return convertToUniversalTime(currentLocalTime());
}

#endif // _TIME_GLSL
