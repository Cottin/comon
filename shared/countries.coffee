 #auto_require: _esramda
import {cc, $} from "ramda-extras" #auto_require: esramda-extras


# # Uncomment to generate - but comment away not to include clm since it's heavy
# import clm from "country-locale-map"
# import {fromCountryCode, defaultFormattingFor} from './sharedUtils'
# aliases = {US: ['usa'], GB: ['uk', 'england', 'britan']}
# totalStr = 'export default [\n'
# allCountries = clm.getAllCountries()
# prioCountries = []
# prioCountries.push $ allCountries, _find _whereEq({alpha2: 'US'})
# prioCountries.push $ allCountries, _find _whereEq({alpha2: 'GB'})
# countriesToUse = [...prioCountries, ...allCountries]
# countries = $ countriesToUse, _map (country) ->
# 	{locale, currency, name} = fromCountryCode country.alpha2
# 	curStr = null
# 	if locale
# 		opts = {style: 'currency', currency, minimumFractionDigits: 0, maximumFractionDigits: 0}
# 		curStr = new Intl.NumberFormat(locale, opts).format(1)

# 	form = defaultFormattingFor country.alpha2

# 	console.log "#{name} - #{currency} - #{form.currencySymbol} - #{curStr}" 

# 	extra = ''
# 	if form.currencySymbol != currency then extra += ", currencySymbol: \"#{form.currencySymbol}\""
# 	if aliases[country.alpha2] then extra += ", alias: #{sf0 aliases[country.alpha2]}"

# 	totalStr += "\t{name: \"#{name}\", alpha2: '#{_toLower country.alpha2}', currency: '#{currency}'#{extra}}\n"


# 	return {name, currency, form}

# totalStr += ']'
# console.log totalStr


# This is ~4kb Gzipped so don't include in bundle, fetch via API-call or use lazy loading with dynamic imports
export default [
	{name: "United States", alpha2: 'us', currency: 'USD', currencySymbol: "$", alias: ["usa"]}
	{name: "United Kingdom", alpha2: 'gb', currency: 'GBP', currencySymbol: "£", alias: ["uk","england","britan"]}
	{name: "Afghanistan", alpha2: 'af', currency: 'AFN'}
	{name: "Albania", alpha2: 'al', currency: 'ALL'}
	{name: "Algeria", alpha2: 'dz', currency: 'DZD', currencySymbol: "‏د.ج.‏"}
	{name: "American Samoa", alpha2: 'as', currency: 'USD', currencySymbol: "$"}
	{name: "Andorra", alpha2: 'ad', currency: 'EUR', currencySymbol: "€"}
	{name: "Angola", alpha2: 'ao', currency: 'AOA'}
	{name: "Anguilla", alpha2: 'ai', currency: 'XCD', currencySymbol: "EC$"}
	{name: "Antarctica", alpha2: 'aq', currency: 'USD', currencySymbol: "$"}
	{name: "Antigua and Barbuda", alpha2: 'ag', currency: 'XCD', currencySymbol: "EC$"}
	{name: "Argentina", alpha2: 'ar', currency: 'ARS', currencySymbol: "$"}
	{name: "Armenia", alpha2: 'am', currency: 'AMD'}
	{name: "Aruba", alpha2: 'aw', currency: 'AWG'}
	{name: "Australia", alpha2: 'au', currency: 'AUD', currencySymbol: "$"}
	{name: "Austria", alpha2: 'at', currency: 'EUR', currencySymbol: "€"}
	{name: "Azerbaijan", alpha2: 'az', currency: 'AZN'}
	{name: "Bahamas", alpha2: 'bs', currency: 'BSD'}
	{name: "Bahrain", alpha2: 'bh', currency: 'BHD', currencySymbol: "‏١د.ب.‏"}
	{name: "Bangladesh", alpha2: 'bd', currency: 'BDT', currencySymbol: "১৳"}
	{name: "Barbados", alpha2: 'bb', currency: 'BBD'}
	{name: "Belarus", alpha2: 'by', currency: 'BYN'}
	{name: "Belgium", alpha2: 'be', currency: 'EUR', currencySymbol: "€"}
	{name: "Belize", alpha2: 'bz', currency: 'BZD', currencySymbol: "$"}
	{name: "Benin", alpha2: 'bj', currency: 'XOF', currencySymbol: "F CFA"}
	{name: "Bermuda", alpha2: 'bm', currency: 'BMD'}
	{name: "Bhutan", alpha2: 'bt', currency: 'BTN'}
	{name: "Bolivia", alpha2: 'bo', currency: 'BTN'}
	{name: "Bonaire", alpha2: 'bq', currency: 'USD', currencySymbol: "US$"}
	{name: "Bosnia and Herzegovina", alpha2: 'ba', currency: 'BAM'}
	{name: "Botswana", alpha2: 'bw', currency: 'BWP', currencySymbol: "P"}
	{name: "Bouvet Island", alpha2: 'bv', currency: 'NOK', currencySymbol: "kr"}
	{name: "Brazil", alpha2: 'br', currency: 'BRL', currencySymbol: "R$"}
	{name: "British Indian Ocean Territory", alpha2: 'io', currency: 'USD', currencySymbol: "$"}
	{name: "Brunei Darussalam", alpha2: 'bn', currency: 'BND', currencySymbol: "$"}
	{name: "Bulgaria", alpha2: 'bg', currency: 'BGN', currencySymbol: "лв."}
	{name: "Burkina Faso", alpha2: 'bf', currency: 'XOF', currencySymbol: "F CFA"}
	{name: "Burundi", alpha2: 'bi', currency: 'BIF', currencySymbol: "FBu"}
	{name: "Cabo Verde", alpha2: 'cv', currency: 'CVE'}
	{name: "Cambodia", alpha2: 'kh', currency: 'KHR'}
	{name: "Cameroon", alpha2: 'cm', currency: 'XAF', currencySymbol: "FCFA"}
	{name: "Canada", alpha2: 'ca', currency: 'CAD', currencySymbol: "$"}
	{name: "Cayman Islands", alpha2: 'ky', currency: 'KYD'}
	{name: "Central African Republic", alpha2: 'cf', currency: 'XAF', currencySymbol: "FCFA"}
	{name: "Chad", alpha2: 'td', currency: 'XAF', currencySymbol: "FCFA"}
	{name: "Chile", alpha2: 'cl', currency: 'CLF'}
	{name: "China", alpha2: 'cn', currency: 'CNY', currencySymbol: "¥"}
	{name: "Christmas Island", alpha2: 'cx', currency: 'AUD', currencySymbol: "A$"}
	{name: "Cocos Islands", alpha2: 'cc', currency: 'AUD', currencySymbol: "A$"}
	{name: "Colombia", alpha2: 'co', currency: 'COU'}
	{name: "Comoros", alpha2: 'km', currency: 'KMF', currencySymbol: "CF"}
	{name: "Democratic Republic of the Congo", alpha2: 'cd', currency: 'CDF', currencySymbol: "FC"}
	{name: "Congo", alpha2: 'cg', currency: 'XAF', currencySymbol: "FCFA"}
	{name: "Cook Islands", alpha2: 'ck', currency: 'NZD', currencySymbol: "NZ$"}
	{name: "Costa Rica", alpha2: 'cr', currency: 'CRC', currencySymbol: "₡"}
	{name: "Croatia", alpha2: 'hr', currency: 'HRK', currencySymbol: "kn"}
	{name: "Cuba", alpha2: 'cu', currency: 'CUC'}
	{name: "Curaçao", alpha2: 'cw', currency: 'ANG'}
	{name: "Cyprus", alpha2: 'cy', currency: 'EUR', currencySymbol: "€"}
	{name: "Czechia", alpha2: 'cz', currency: 'CZK', currencySymbol: "Kč"}
	{name: "Côte d'Ivoire", alpha2: 'ci', currency: 'CZK'}
	{name: "Denmark", alpha2: 'dk', currency: 'DKK', currencySymbol: "kr."}
	{name: "Djibouti", alpha2: 'dj', currency: 'DJF', currencySymbol: "Fdj"}
	{name: "Dominica", alpha2: 'dm', currency: 'XCD', currencySymbol: "EC$"}
	{name: "Dominican Republic", alpha2: 'do', currency: 'DOP', currencySymbol: "RD$"}
	{name: "Ecuador", alpha2: 'ec', currency: 'USD', currencySymbol: "$"}
	{name: "Egypt", alpha2: 'eg', currency: 'EGP', currencySymbol: "‏١ج.م.‏"}
	{name: "El Salvador", alpha2: 'sv', currency: 'USD', currencySymbol: "$"}
	{name: "Equatorial Guinea", alpha2: 'gq', currency: 'XAF', currencySymbol: "FCFA"}
	{name: "Eritrea", alpha2: 'er', currency: 'ERN'}
	{name: "Estonia", alpha2: 'ee', currency: 'EUR', currencySymbol: "€"}
	{name: "Eswatini", alpha2: 'sz', currency: 'EUR', currencySymbol: "€"}
	{name: "Ethiopia", alpha2: 'et', currency: 'ETB', currencySymbol: "ብር"}
	{name: "Falkland Islands", alpha2: 'fk', currency: 'DKK'}
	{name: "Faroe Islands", alpha2: 'fo', currency: 'DKK'}
	{name: "Fiji", alpha2: 'fj', currency: 'FJD'}
	{name: "Finland", alpha2: 'fi', currency: 'EUR', currencySymbol: "€"}
	{name: "France", alpha2: 'fr', currency: 'EUR', currencySymbol: "€"}
	{name: "French Guiana", alpha2: 'gf', currency: 'EUR', currencySymbol: "€"}
	{name: "French Polynesia", alpha2: 'pf', currency: 'XPF', currencySymbol: "FCFP"}
	{name: "French Southern Territories", alpha2: 'tf', currency: 'EUR', currencySymbol: "€"}
	{name: "Gabon", alpha2: 'ga', currency: 'XAF', currencySymbol: "FCFA"}
	{name: "Gambia", alpha2: 'gm', currency: 'GMD'}
	{name: "Georgia", alpha2: 'ge', currency: 'GEL'}
	{name: "Germany", alpha2: 'de', currency: 'EUR', currencySymbol: "€"}
	{name: "Ghana", alpha2: 'gh', currency: 'GHS'}
	{name: "Gibraltar", alpha2: 'gi', currency: 'GIP'}
	{name: "Greece", alpha2: 'gr', currency: 'EUR', currencySymbol: "€"}
	{name: "Greenland", alpha2: 'gl', currency: 'DKK'}
	{name: "Grenada", alpha2: 'gd', currency: 'XCD', currencySymbol: "EC$"}
	{name: "Guadeloupe", alpha2: 'gp', currency: 'EUR', currencySymbol: "€"}
	{name: "Guam", alpha2: 'gu', currency: 'USD', currencySymbol: "$"}
	{name: "Guatemala", alpha2: 'gt', currency: 'GTQ', currencySymbol: "Q"}
	{name: "Guernsey", alpha2: 'gg', currency: 'GBP', currencySymbol: "£"}
	{name: "Guinea", alpha2: 'gn', currency: 'GNF', currencySymbol: "FG"}
	{name: "Guinea-Bissau", alpha2: 'gw', currency: 'XOF', currencySymbol: "F CFA"}
	{name: "Guyana", alpha2: 'gy', currency: 'GYD'}
	{name: "Haiti", alpha2: 'ht', currency: 'USD', currencySymbol: "$US"}
	{name: "Heard Island and McDonald Islands", alpha2: 'hm', currency: 'AUD', currencySymbol: "A$"}
	{name: "Holy See", alpha2: 'va', currency: 'EUR', currencySymbol: "€"}
	{name: "Honduras", alpha2: 'hn', currency: 'HNL', currencySymbol: "L"}
	{name: "Hong Kong", alpha2: 'hk', currency: 'HKD', currencySymbol: "HK$"}
	{name: "Hungary", alpha2: 'hu', currency: 'HUF', currencySymbol: "Ft"}
	{name: "Iceland", alpha2: 'is', currency: 'ISK'}
	{name: "India", alpha2: 'in', currency: 'INR', currencySymbol: "₹"}
	{name: "Indonesia", alpha2: 'id', currency: 'IDR', currencySymbol: "Rp"}
	{name: "Iran", alpha2: 'ir', currency: 'XDR', currencySymbol: "‎XDR۱"}
	{name: "Iraq", alpha2: 'iq', currency: 'IQD', currencySymbol: "‏١د.ع.‏"}
	{name: "Ireland", alpha2: 'ie', currency: 'EUR', currencySymbol: "€"}
	{name: "Isle of Man", alpha2: 'im', currency: 'GBP', currencySymbol: "£"}
	{name: "Israel", alpha2: 'il', currency: 'ILS', currencySymbol: "‏‏₪"}
	{name: "Italy", alpha2: 'it', currency: 'EUR', currencySymbol: "€"}
	{name: "Jamaica", alpha2: 'jm', currency: 'JMD', currencySymbol: "$"}
	{name: "Japan", alpha2: 'jp', currency: 'JPY', currencySymbol: "￥"}
	{name: "Jersey", alpha2: 'je', currency: 'GBP', currencySymbol: "£"}
	{name: "Jordan", alpha2: 'jo', currency: 'JOD', currencySymbol: "‏١د.أ.‏"}
	{name: "Kazakhstan", alpha2: 'kz', currency: 'KZT'}
	{name: "Kenya", alpha2: 'ke', currency: 'KES'}
	{name: "Kiribati", alpha2: 'ki', currency: 'AUD', currencySymbol: "A$"}
	{name: "North Korea", alpha2: 'kp', currency: 'KPW'}
	{name: "South Korea", alpha2: 'kr', currency: 'KRW', currencySymbol: "₩"}
	{name: "Kuwait", alpha2: 'kw', currency: 'KWD', currencySymbol: "‏١د.ك.‏"}
	{name: "Kyrgyzstan", alpha2: 'kg', currency: 'KGS'}
	{name: "Lao People's Democratic Republic", alpha2: 'la', currency: 'LAK'}
	{name: "Latvia", alpha2: 'lv', currency: 'EUR', currencySymbol: "€"}
	{name: "Lebanon", alpha2: 'lb', currency: 'LBP', currencySymbol: "‏١ل.ل.‏"}
	{name: "Lesotho", alpha2: 'ls', currency: 'ZAR'}
	{name: "Liberia", alpha2: 'lr', currency: 'LRD'}
	{name: "Libya", alpha2: 'ly', currency: 'LYD', currencySymbol: "‏د.ل.‏"}
	{name: "Liechtenstein", alpha2: 'li', currency: 'CHF'}
	{name: "Lithuania", alpha2: 'lt', currency: 'EUR', currencySymbol: "€"}
	{name: "Luxembourg", alpha2: 'lu', currency: 'EUR', currencySymbol: "€"}
	{name: "Macao", alpha2: 'mo', currency: 'MOP'}
	{name: "Madagascar", alpha2: 'mg', currency: 'MGA', currencySymbol: "Ar"}
	{name: "Malawi", alpha2: 'mw', currency: 'MWK'}
	{name: "Malaysia", alpha2: 'my', currency: 'MYR', currencySymbol: "RM"}
	{name: "Maldives", alpha2: 'mv', currency: 'MVR'}
	{name: "Mali", alpha2: 'ml', currency: 'XOF', currencySymbol: "F CFA"}
	{name: "Malta", alpha2: 'mt', currency: 'EUR', currencySymbol: "€"}
	{name: "Marshall Islands", alpha2: 'mh', currency: 'USD', currencySymbol: "$"}
	{name: "Martinique", alpha2: 'mq', currency: 'EUR', currencySymbol: "€"}
	{name: "Mauritania", alpha2: 'mr', currency: 'MRU', currencySymbol: "‏أ.م."}
	{name: "Mauritius", alpha2: 'mu', currency: 'MUR', currencySymbol: "Rs"}
	{name: "Mayotte", alpha2: 'yt', currency: 'EUR', currencySymbol: "€"}
	{name: "Mexico", alpha2: 'mx', currency: 'MXV'}
	{name: "Micronesia", alpha2: 'fm', currency: 'RUB'}
	{name: "Moldova", alpha2: 'md', currency: 'MDL', currencySymbol: "L"}
	{name: "Monaco", alpha2: 'mc', currency: 'EUR', currencySymbol: "€"}
	{name: "Mongolia", alpha2: 'mn', currency: 'MNT'}
	{name: "Montenegro", alpha2: 'me', currency: 'EUR'}
	{name: "Montserrat", alpha2: 'ms', currency: 'XCD', currencySymbol: "EC$"}
	{name: "Morocco", alpha2: 'ma', currency: 'MAD', currencySymbol: "‏د.م.‏"}
	{name: "Mozambique", alpha2: 'mz', currency: 'MZN', currencySymbol: "MTn"}
	{name: "Myanmar", alpha2: 'mm', currency: 'MMK'}
	{name: "Namibia", alpha2: 'na', currency: 'ZAR'}
	{name: "Nauru", alpha2: 'nr', currency: 'AUD', currencySymbol: "A$"}
	{name: "Nepal", alpha2: 'np', currency: 'NPR'}
	{name: "Netherlands", alpha2: 'nl', currency: 'EUR', currencySymbol: "€"}
	{name: "New Caledonia", alpha2: 'nc', currency: 'XPF', currencySymbol: "FCFP"}
	{name: "New Zealand", alpha2: 'nz', currency: 'NZD', currencySymbol: "$"}
	{name: "Nicaragua", alpha2: 'ni', currency: 'NIO', currencySymbol: "C$"}
	{name: "Niger", alpha2: 'ne', currency: 'XOF', currencySymbol: "F CFA"}
	{name: "Nigeria", alpha2: 'ng', currency: 'NGN'}
	{name: "Niue", alpha2: 'nu', currency: 'NZD', currencySymbol: "NZ$"}
	{name: "Norfolk Island", alpha2: 'nf', currency: 'AUD', currencySymbol: "A$"}
	{name: "North Macedonia", alpha2: 'mk', currency: 'AUD', currencySymbol: "A$"}
	{name: "Northern Mariana Islands", alpha2: 'mp', currency: 'USD', currencySymbol: "$"}
	{name: "Norway", alpha2: 'no', currency: 'NOK', currencySymbol: "kr"}
	{name: "Oman", alpha2: 'om', currency: 'OMR', currencySymbol: "‏١ر.ع.‏"}
	{name: "Pakistan", alpha2: 'pk', currency: 'PKR', currencySymbol: "Rs"}
	{name: "Palau", alpha2: 'pw', currency: 'USD', currencySymbol: "$"}
	{name: "Palestine", alpha2: 'ps', currency: 'USD', currencySymbol: "‏US$"}
	{name: "Panama", alpha2: 'pa', currency: 'USD'}
	{name: "Papua New Guinea", alpha2: 'pg', currency: 'PGK'}
	{name: "Paraguay", alpha2: 'py', currency: 'PYG', currencySymbol: "Gs."}
	{name: "Peru", alpha2: 'pe', currency: 'PEN', currencySymbol: "S/"}
	{name: "Philippines", alpha2: 'ph', currency: 'PHP', currencySymbol: "₱"}
	{name: "Pitcairn", alpha2: 'pn', currency: 'NZD', currencySymbol: "NZ$"}
	{name: "Poland", alpha2: 'pl', currency: 'PLN', currencySymbol: "zł"}
	{name: "Portugal", alpha2: 'pt', currency: 'EUR', currencySymbol: "€"}
	{name: "Puerto Rico", alpha2: 'pr', currency: 'USD', currencySymbol: "$"}
	{name: "Qatar", alpha2: 'qa', currency: 'QAR', currencySymbol: "‏١ر.ق.‏"}
	{name: "Romania", alpha2: 'ro', currency: 'RON'}
	{name: "Russia", alpha2: 'ru', currency: 'RUB', currencySymbol: "₽"}
	{name: "Rwanda", alpha2: 'rw', currency: 'RWF', currencySymbol: "RF"}
	{name: "Réunion", alpha2: 're', currency: 'RWF'}
	{name: "Saint Barthélemy", alpha2: 'bl', currency: 'EUR', currencySymbol: "€"}
	{name: "Saint Helena", alpha2: 'sh', currency: 'SHP'}
	{name: "Saint Kitts and Nevis", alpha2: 'kn', currency: 'XCD', currencySymbol: "EC$"}
	{name: "Saint Lucia", alpha2: 'lc', currency: 'XCD', currencySymbol: "EC$"}
	{name: "Saint Martin", alpha2: 'mf', currency: 'EUR', currencySymbol: "€"}
	{name: "Saint Pierre and Miquelon", alpha2: 'pm', currency: 'EUR', currencySymbol: "€"}
	{name: "Saint Vincent and the Grenadines", alpha2: 'vc', currency: 'XCD', currencySymbol: "EC$"}
	{name: "Samoa", alpha2: 'ws', currency: 'WST'}
	{name: "San Marino", alpha2: 'sm', currency: 'EUR', currencySymbol: "€"}
	{name: "Sao Tome and Principe", alpha2: 'st', currency: 'STN'}
	{name: "Saudi Arabia", alpha2: 'sa', currency: 'SAR', currencySymbol: "‏١ر.س.‏"}
	{name: "Senegal", alpha2: 'sn', currency: 'XOF', currencySymbol: "F CFA"}
	{name: "Serbia", alpha2: 'rs', currency: 'RSD'}
	{name: "Seychelles", alpha2: 'sc', currency: 'SCR'}
	{name: "Sierra Leone", alpha2: 'sl', currency: 'SLL'}
	{name: "Singapore", alpha2: 'sg', currency: 'SGD', currencySymbol: "$"}
	{name: "Sint Maarten", alpha2: 'sx', currency: 'ANG'}
	{name: "Slovakia", alpha2: 'sk', currency: 'EUR', currencySymbol: "€"}
	{name: "Slovenia", alpha2: 'si', currency: 'EUR', currencySymbol: "€"}
	{name: "Solomon Islands", alpha2: 'sb', currency: 'SBD'}
	{name: "Somalia", alpha2: 'so', currency: 'SOS'}
	{name: "South Africa", alpha2: 'za', currency: 'ZAR', currencySymbol: "R"}
	{name: "South Georgia and the South Sandwich Islands", alpha2: 'gs', currency: 'USD', currencySymbol: "$"}
	{name: "South Sudan", alpha2: 'ss', currency: 'SSP'}
	{name: "Spain", alpha2: 'es', currency: 'EUR', currencySymbol: "€"}
	{name: "Sri Lanka", alpha2: 'lk', currency: 'LKR'}
	{name: "Sudan", alpha2: 'sd', currency: 'SDG', currencySymbol: "‏١ج.س."}
	{name: "Suriname", alpha2: 'sr', currency: 'SRD'}
	{name: "Svalbard and Jan Mayen", alpha2: 'sj', currency: 'NOK', currencySymbol: "kr"}
	{name: "Sweden", alpha2: 'se', currency: 'SEK', currencySymbol: "kr"}
	{name: "Switzerland", alpha2: 'ch', currency: 'CHW'}
	{name: "Syrian Arab Republic", alpha2: 'sy', currency: 'SYP', currencySymbol: "‏١ل.س.‏"}
	{name: "Taiwan", alpha2: 'tw', currency: 'TWD'}
	{name: "Tajikistan", alpha2: 'tj', currency: 'TJS'}
	{name: "Tanzania", alpha2: 'tz', currency: 'TZS'}
	{name: "Thailand", alpha2: 'th', currency: 'THB', currencySymbol: "฿"}
	{name: "Timor-Leste", alpha2: 'tl', currency: 'USD', currencySymbol: "US$"}
	{name: "Togo", alpha2: 'tg', currency: 'XOF', currencySymbol: "F CFA"}
	{name: "Tokelau", alpha2: 'tk', currency: 'NZD', currencySymbol: "NZ$"}
	{name: "Tonga", alpha2: 'to', currency: 'TOP'}
	{name: "Trinidad and Tobago", alpha2: 'tt', currency: 'TTD', currencySymbol: "$"}
	{name: "Tunisia", alpha2: 'tn', currency: 'TND', currencySymbol: "‏د.ت.‏"}
	{name: "Turkey", alpha2: 'tr', currency: 'TRY', currencySymbol: "₺"}
	{name: "Turkmenistan", alpha2: 'tm', currency: 'TMT'}
	{name: "Turks and Caicos Islands", alpha2: 'tc', currency: 'USD', currencySymbol: "$"}
	{name: "Tuvalu", alpha2: 'tv', currency: 'AUD', currencySymbol: "A$"}
	{name: "Uganda", alpha2: 'ug', currency: 'UGX'}
	{name: "Ukraine", alpha2: 'ua', currency: 'UAH', currencySymbol: "грн"}
	{name: "United Arab Emirates", alpha2: 'ae', currency: 'AED', currencySymbol: "‏د.إ.‏"}
	{name: "United Kingdom", alpha2: 'gb', currency: 'GBP', currencySymbol: "£", alias: ["uk","england","britan"]}
	{name: "United States Minor Outlying Islands", alpha2: 'um', currency: 'USD', currencySymbol: "$"}
	{name: "United States", alpha2: 'us', currency: 'USD', currencySymbol: "$", alias: ["usa"]}
	{name: "Uruguay", alpha2: 'uy', currency: 'UYW'}
	{name: "Uzbekistan", alpha2: 'uz', currency: 'UZS'}
	{name: "Vanuatu", alpha2: 'vu', currency: 'VUV'}
	{name: "Venezuela", alpha2: 've', currency: 'VUV'}
	{name: "Viet Nam", alpha2: 'vn', currency: 'VND', currencySymbol: "₫"}
	{name: "Virgin Islands (British)", alpha2: 'vg', currency: 'USD', currencySymbol: "$"}
	{name: "Virgin Islands (U.S.)", alpha2: 'vi', currency: 'USD', currencySymbol: "$"}
	{name: "Wallis and Futuna", alpha2: 'wf', currency: 'XPF', currencySymbol: "FCFP"}
	{name: "Western Sahara", alpha2: 'eh', currency: 'MAD'}
	{name: "Yemen", alpha2: 'ye', currency: 'YER', currencySymbol: "‏١ر.ي.‏"}
	{name: "Zambia", alpha2: 'zm', currency: 'ZMW'}
	{name: "Zimbabwe", alpha2: 'zw', currency: 'ZWL'}
	{name: "Åland Islands", alpha2: 'ax', currency: 'EUR', currencySymbol: "€"}
]