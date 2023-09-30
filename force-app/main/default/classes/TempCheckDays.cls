public class TempCheckDays {
    public static void checkCurrentDay() {
        Datetime today = System.now();
        String dayOfWeek = today.format('EEEE');
        
        System.debug('Today is ' + dayOfWeek);
        
        if (dayOfWeek == 'Saturday' || dayOfWeek == 'Sunday') {
            System.debug('Enjoy, it\'s the weekend!');
        } else {
            System.debug('It\'s a working day.');
        }
    }
}