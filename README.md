# InvestTrack India - Complete Flutter Source Code

This is the complete source code for **InvestTrack India**, a privacy-focused investment tracking app built with Flutter following MVVM Clean Architecture principles.

## 🏗️ Architecture Overview

The application follows a clean, modular architecture:

```
InvestTrack India/
├── lib/
│   ├── main.dart                           # App entry point
│   ├── models/
│   │   └── investment_model.dart           # Investment data models with Hive annotations
│   ├── services/
│   │   └── local_db_service.dart          # Hive database operations
│   ├── providers/
│   │   └── investment_provider.dart        # Riverpod state management
│   ├── screens/
│   │   ├── dashboard_screen.dart          # Main dashboard with portfolio overview
│   │   ├── add_investment_screen.dart     # Add/Edit investment forms
│   │   └── investment_list_screen.dart    # Investment list with filtering
│   ├── widgets/
│   │   ├── investment_form_fields.dart    # Dynamic form fields per investment type
│   │   ├── pie_chart_widget.dart         # Interactive portfolio allocation chart
│   │   └── investment_tile.dart          # Investment display component
│   └── utils/
│       ├── constants.dart                 # App constants and strings
│       └── helpers.dart                   # Currency formatting and calculations
└── pubspec.yaml                           # Dependencies and configuration
```

## 🔥 Key Features Implemented

### 💰 **Indian Currency Support**
- **₹ (Rupee) Symbol**: All amounts displayed with proper Indian currency symbol
- **Indian Number Format**: Uses `en_IN` locale for proper comma placement (₹1,00,000.00)
- **Compact Format**: Large amounts shown as ₹1.5L, ₹2.3Cr for better readability
- **Validation**: Proper amount validation for Indian currency inputs

### 🏦 **Investment Types Supported**
1. **Fixed Deposit (FD)** - FD number, bank, interest rate, compounding frequency
2. **Recurring Deposit (RD)** - Monthly amount, tenure, bank details
3. **Public Provident Fund (PPF)** - Account number, yearly contribution, 15-year lock-in
4. **National Pension Scheme (NPS)** - NPS number, tier, asset allocation
5. **Mutual Funds** (Equity/Debt/Hybrid) - Fund name, SIP/lumpsum, NAV, units, AMC
6. **Stocks** - Symbol, exchange (NSE/BSE), quantity, average price
7. **Gold** (Physical/ETF/Digital) - Type, units/weight, purity
8. **Real Estate** - Property details, location, purchase price
9. **EPF** - Employee Provident Fund tracking
10. **ULIP** - Unit-linked insurance plans
11. **Bonds** - Government and corporate bonds
12. **Cryptocurrency** - Digital asset tracking
13. **Other** - Custom investment categories

### 📊 **Advanced Calculations**
- **Current Value Calculation**: Real-time portfolio valuation
- **Gains/Loss Tracking**: Absolute and percentage gains/losses
- **CAGR Calculation**: Compound Annual Growth Rate
- **SIP Maturity Calculator**: Future value projections
- **FD Maturity Calculator**: Compound interest calculations
- **Portfolio Allocation**: Category-wise investment distribution

### 🎨 **Modern UI/UX**
- **Material Design 3**: Latest design system implementation
- **Interactive Charts**: fl_chart integration for portfolio visualization
- **Responsive Design**: Optimized for all screen sizes
- **Dark/Light Theme**: System theme support
- **Intuitive Navigation**: Bottom navigation with floating action button

### 🔐 **Privacy & Security**
- **100% Local Storage**: All data stored locally using Hive database
- **No Cloud Dependency**: Zero data transmission to external servers
- **Offline-First Design**: Works completely offline
- **Secure Storage Ready**: Integration points for biometric authentication
- **Data Encryption Ready**: Structure for AES encryption implementation

## 🔧 Technical Implementation

### **State Management - Riverpod**
```dart
// Investment list provider with async state handling
final investmentListProvider = StateNotifierProvider<InvestmentNotifier, AsyncValue<List<Investment>>>();

// Portfolio statistics computed provider
final investmentStatsProvider = Provider<InvestmentStats>();

// Portfolio allocation pie chart data
final portfolioAllocationProvider = Provider<Map<String, double>>();
```

### **Database - Hive NoSQL**
```dart
@HiveType(typeId: 0)
class Investment extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) String name;
  @HiveField(2) InvestmentType type;
  @HiveField(3) double amount; // Amount in INR
  // ... additional fields
}
```

### **Dynamic Forms**
The app includes intelligent form generation based on investment type:
- **Fixed Deposit**: FD number, bank, interest rate, maturity date
- **Mutual Fund**: Fund name, AMC, SIP/lumpsum, NAV, units
- **Stocks**: Symbol, exchange, quantity, average price
- **Gold**: Type, quantity/weight, purity (for physical gold)

### **Currency Formatting**
```dart
class CurrencyHelper {
  static String formatAmount(double amount) {
    return NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(amount);
  }
  
  static String formatCompactAmount(double amount) {
    if (amount >= 10000000) return '₹${(amount/10000000).toStringAsFixed(1)}Cr';
    if (amount >= 100000) return '₹${(amount/100000).toStringAsFixed(1)}L';
    return formatAmount(amount);
  }
}
```

## 📱 Screens & Navigation

### **Dashboard Screen**
- Portfolio summary cards with total value, invested amount, gains/loss
- Interactive pie chart showing asset allocation
- Recent investments list
- Quick statistics (total investments, active, matured)

### **Add Investment Screen**
- Investment type selection dropdown
- Dynamic form fields based on selected type
- Date pickers for start/maturity dates
- Amount validation with Indian currency support
- Edit/delete functionality for existing investments

### **Investment List Screen**
- Complete list of all investments
- Search functionality by investment name
- Filter by type, status, and sort options
- Pull-to-refresh capability
- Empty state handling

## 🚀 Getting Started

### **Prerequisites**
- Flutter SDK (>=3.0.0)
- Android Studio / VS Code
- Android/iOS emulator or physical device

### **Installation Steps**

1. **Clone the project** (files are provided above)

2. **Navigate to project directory**
   ```bash
   cd investtrack_india
   ```

3. **Install dependencies**
   ```bash
   flutter pub get
   ```

4. **Generate Hive type adapters**
   ```bash
   flutter packages pub run build_runner build
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

## 📦 Dependencies Used

### **Core Dependencies**
- `flutter_riverpod: ^2.4.9` - State management
- `hive: ^4.0.0-dev.2` - Local NoSQL database
- `hive_flutter: ^1.1.0` - Flutter integration for Hive
- `fl_chart: ^0.65.0` - Interactive charts
- `intl: ^0.19.0` - Internationalization and currency formatting
- `uuid: ^4.1.0` - Unique ID generation

### **Development Dependencies**
- `hive_generator: ^2.0.1` - Code generation for Hive
- `build_runner: ^2.4.7` - Build system
- `flutter_lints: ^3.0.0` - Linting rules

### **Security (Ready for Integration)**
- `flutter_secure_storage: ^9.0.0` - Secure storage
- `local_auth: ^2.1.6` - Biometric authentication

## 🔮 Future Enhancements

### **Security Features**
- Biometric authentication (fingerprint, face ID)
- PIN-based app lock
- Data encryption using AES
- Secure backup/restore functionality

### **Advanced Features**
- Market data API integration (NSE/BSE, mutual fund NAV)
- Tax calculation and planning (80C, 80CCD)
- Goal-based investment planning
- SIP reminder notifications
- Multi-language support (Hindi, regional languages)

### **Analytics & Reporting**
- Advanced portfolio analytics
- Investment performance comparison
- PDF report generation
- CSV/Excel export functionality
- Historical performance tracking

## 📋 Code Quality & Architecture

### **MVVM Pattern Implementation**
- **Model**: Data models with business logic
- **View**: UI screens and widgets
- **ViewModel**: Riverpod providers managing state and business logic

### **Clean Architecture Principles**
- **Separation of Concerns**: Clear layer separation
- **Dependency Inversion**: Abstract interfaces for data sources
- **Single Responsibility**: Each class has one responsibility
- **Testability**: Architecture supports easy unit testing

### **Best Practices Followed**
- Proper error handling with AsyncValue
- Form validation with user-friendly messages
- Responsive design with proper spacing
- Accessibility considerations
- Code documentation and comments
- Consistent naming conventions

## 🎯 Production Readiness

The codebase includes all essential features for a production-ready investment tracking app:

✅ **Complete CRUD Operations** - Add, view, edit, delete investments
✅ **Data Persistence** - Reliable local storage with Hive
✅ **Error Handling** - Comprehensive error states and user feedback
✅ **Input Validation** - Proper form validation and sanitization
✅ **Performance Optimized** - Efficient state management and rendering
✅ **User Experience** - Intuitive navigation and responsive design
✅ **Indian Market Focus** - Currency, investment types, and regulations
✅ **Privacy Compliant** - No data collection or external transmission

## 📞 Support & Customization

This source code provides a solid foundation that can be extended with additional features:

- **Custom Investment Types**: Easy to add new investment categories
- **API Integration**: Structure ready for market data APIs
- **Theme Customization**: Material Design 3 theming system
- **Localization**: Internationalization framework in place
- **Platform Features**: Ready for platform-specific features

The app follows Flutter best practices and can be easily maintained, tested, and scaled for production use.