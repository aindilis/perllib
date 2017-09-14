package System::WWW::GEPIR;

use PerlLib::SwissArmyKnife;

use HTML::TableExtract;
use WWW::Mechanize;

# system to retrieve  images from google images, using  a local cache,
# with the possibility of selection, and a few other criteria

use Class::MethodMaker
  new_with_init => 'new',
  get_set =>
  [
   qw / Mech DdlCountryList MySayer iDdlCountryList /
  ];

sub init {
  my ($self,%args) = @_;
  $UNIVERSAL::systemwwwgepir = $self;
  $self->Mech
    (WWW::Mechanize->new());
  $self->LoadDdlCountryList();
  die "No sayer defined\n" unless defined $args{Sayer};
  $self->MySayer($args{Sayer});
}

sub SearchByName {
  my ($self,%args) = @_;
  my $url = "http://gepir.gs1.org/v32/xx/search_by_name.aspx?Lang=en-US";
  my $content;
  if (1) {
    $self->Mech->get($url);
    # my @forms = $self->Mech->forms();
    my $fields = {
		  ddlCountry => $args{Country} || "US", # "UNITED STATES (3.0)",
		  txtRequestNAME => $args{CompanyName},
		 };
    my $r = $self->Mech->submit_form
      (
       form_number => 1,
       fields => $fields,
       button => "btnSubmitSearch_by_name",
      );
    $content = $self->Mech->content();
  } else {
    $content = read_file("/var/lib/myfrdcsa/codebases/minor/elle-ethical-consumer/subsys/source-analysis/source/ethical-consumer/result.html");
  }
  return
    {
     Success => 1,
     Result => $self->ProcessResults(Content => $content),
    };
}

sub ProcessResults {
  my ($self,%args) = @_;
  my $c = $args{Content};
  if ($c =~ /(<table id="resultTable".+?<\/table>)/s) {
    my $tabletext = $1;
    my $te = HTML::TableExtract->new();
    $te->parse($tabletext);
    my $row = 0;
    my @results;
    foreach $ts ($te->rows) {
      my $rowresult = {};
      # print Dumper($ts);
      my $col = 0;
      foreach my $entry (@$ts) {
	$entry =~ s/^\s*//s;
	$entry =~ s/\s*$//s;
	if ($row == 0) {
	  push @names, $entry;
	} else {
	  $rowresult->{$names[$col]} = $entry;
	}
	++$col;
      }
      if ($row > 0) {
	push @results, $rowresult;
      }
      ++$row;

    }
    # print Dumper(\@results);
    return {
	    Success => 1,
	    Result => \@results,
	   };
  } else {
    return {
	    Success => 0,
	    Error => "Results do not have the table",
	   };
  }
}

sub SearchByBarcode {
  my ($self,%args) = @_;
  my $url = "http://gepir.gs1.org/v32/xx/gtin.aspx?Lang=en-US";
  $self->Mech->get($url);
}

sub LoadDdlCountryList {
  my ($self,%args) = @_;

  # FIXME replace with something that pulls this information from the
  # form

  $self->DdlCountryList
    ({
      AF => "AFGHANISTAN (3.2)",
      AL => "ALBANIA (3.2)",
      DZ => "ALGERIA (3.2)",
      AS => "AMERICAN SAMOA (N/A)",
      AD => "ANDORRA (N/A)",
      AO => "ANGOLA (3.2)",
      AI => "ANGUILLA (N/A)",
      AQ => "ANTARCTICA (N/A)",
      AG => "ANTIGUA AND BARBUDA (N/A)",
      AR => "ARGENTINA (3.2)",
      AM => "ARMENIA (3.2)",
      AW => "ARUBA (3.2)",
      AU => "AUSTRALIA (3.2)",
      AT => "AUSTRIA (3.1)",
      AZ => "AZERBAIJAN (3.2)",
      BS => "BAHAMAS (3.2)",
      BH => "BAHRAIN (N/A)",
      BD => "BANGLADESH (3.2)",
      BB => "BARBADOS (3.2)",
      BY => "BELARUS (3.0)",
      BE => "BELGIUM (3.1)",
      BZ => "BELIZE (3.2)",
      BJ => "BENIN (3.2)",
      BM => "BERMUDA (N/A)",
      BT => "BHUTAN (N/A)",
      BO => "BOLIVIA (3.2)",
      BA => "BOSNIA AND HERZEGOVINA (3.2)",
      BW => "BOTSWANA (3.2)",
      BV => "BOUVET ISLAND (N/A)",
      BR => "BRAZIL (3.0)",
      IO => "BRITISH INDIAN OCEAN TERRITORY (N/A)",
      BN => "BRUNEI (3.2)",
      BG => "BULGARIA (3.2)",
      BF => "BURKINA FASO (N/A)",
      BI => "BURUNDI (3.2)",
      KH => "CAMBODIA (3.2)",
      CM => "CAMEROON (3.2)",
      CA => "CANADA (3.0)",
      CV => "CAPE VERDE (3.2)",
      KY => "CAYMAN ISLANDS (3.2)",
      CF => "CENTRAL AFRICAN REPUBLIC (N/A)",
      TD => "CHAD (N/A)",
      CL => "CHILE (3.2)",
      CN => "CHINA (3.1)",
      MO => "CHINA (MACAU S.A.R.) (N/A)",
      CX => "CHRISTMAS ISLAND (N/A)",
      CC => "COCOS (KEELING) ISLANDS (N/A)",
      CO => "COLOMBIA (3.1)",
      KM => "COMOROS (N/A)",
      CG => "CONGO (N/A)",
      CD => "CONGO DEMOCRATIC REPUBLIC (3.2)",
      CK => "COOK ISLANDS (N/A)",
      CR => "COSTA RICA (3.1)",
      HR => "CROATIA (3.2)",
      CU => "CUBA (N/A)",
      CY => "CYPRUS (2.0)",
      CZ => "CZECH REPUBLIC (3.1)",
      DK => "DENMARK (3.2)",
      DJ => "DJIBOUTI (3.2)",
      DM => "DOMINICA (N/A)",
      DO => "DOMINICAN REPUBLIC (3.2)",
      TP => "EAST TIMOR (N/A)",
      EC => "ECUADOR (N/A)",
      EG => "EGYPT (3.2)",
      SV => "EL SALVADOR (3.1)",
      GQ => "EQUATORIAL GUINEA (N/A)",
      ER => "ERITREA (N/A)",
      EE => "ESTONIA (3.1)",
      ET => "ETHIOPIA (3.2)",
      FK => "FALKLAND ISLANDS (N/A)",
      FO => "FAROE ISLANDS (3.2)",
      FJ => "FIJI ISLANDS (N/A)",
      FI => "FINLAND (3.2)",
      FR => "FRANCE (3.1)",
      GF => "FRENCH GUIANA (N/A)",
      PF => "FRENCH POLYNESIA (N/A)",
      TF => "FRENCH SOUTHERN TERRITORIES (N/A)",
      GA => "GABON (3.2)",
      GM => "GAMBIA (3.2)",
      GE => "GEORGIA (3.2)",
      DE => "GERMANY (3.1)",
      GH => "GHANA (3.2)",
      GI => "GIBRALTAR (3.2)",
      GR => "GREECE (3.2)",
      GL => "GREENLAND (3.2)",
      GD => "GRENADA (N/A)",
      GP => "GUADELOUPE (N/A)",
      GU => "GUAM (N/A)",
      GT => "GUATEMALA (3.2)",
      GN => "GUINEA (3.2)",
      GW => "GUINEA-BISSAU (N/A)",
      GY => "GUYANA (3.2)",
      HT => "HAITI (3.2)",
      HM => "HEARD AND MCDONALD ISLANDS (N/A)",
      HN => "HONDURAS (3.1)",
      HK => "HONG KONG (2.0)",
      HU => "HUNGARY (3.1)",
      IS => "ICELAND (3.2)",
      IN => "INDIA (3.1)",
      ID => "INDONESIA (3.2)",
      IR => "IRAN (3.2)",
      IE => "IRELAND (3.2)",
      IL => "ISRAEL (N/A)",
      IT => "ITALY (3.0)",
      CI => "IVORY COAST (3.2)",
      JM => "JAMAICA (3.2)",
      JP => "JAPAN (3.0)",
      JO => "JORDAN (3.2)",
      KZ => "KAZAKHSTAN (3.2)",
      KE => "KENYA (3.2)",
      KI => "KIRIBATI (N/A)",
      KR => "KOREA (3.1)",
      KP => "KOREA, NORTH (N/A)",
      KW => "KUWAIT (N/A)",
      KG => "KYRGYZSTAN (3.2)",
      LA => "LAOS (3.2)",
      LV => "LATVIA (3.1)",
      LB => "LEBANON (3.2)",
      LS => "LESOTHO (N/A)",
      LR => "LIBERIA (N/A)",
      LY => "LIBYAN ARAB JAMAHIRY (3.2)",
      LI => "LIECHTENSTEIN (3.1)",
      LT => "LITHUANIA (3.2)",
      LU => "LUXEMBOURG (3.1)",
      MK => "MACEDONIA (3.2)",
      MG => "MADAGASCAR (3.2)",
      MW => "MALAWI (N/A)",
      MY => "MALAYSIA (3.2)",
      MV => "MALDIVES (3.2)",
      ML => "MALI (N/A)",
      MT => "MALTA (3.2)",
      MH => "MARSHALL ISLANDS (N/A)",
      MQ => "MARTINIQUE (N/A)",
      MR => "MAURITANIA (3.2)",
      MU => "MAURITIUS (3.2)",
      YT => "MAYOTTE (N/A)",
      MX => "MEXICO (3.1)",
      FM => "MICRONESIA (N/A)",
      MD => "MOLDOVA (2.0)",
      MC => "MONACO (3.2)",
      MN => "MONGOLIA (3.2)",
      ME => "MONTENEGRO (3.2)",
      MS => "MONTSERRAT (N/A)",
      MA => "MOROCCO (3.2)",
      MZ => "MOZAMBIQUE (3.2)",
      MM => "MYANMAR (3.2)",
      NA => "NAMIBIA (N/A)",
      NR => "NAURU (N/A)",
      NP => "NEPAL (3.2)",
      NL => "NETHERLANDS (3.2)",
      AN => "NETHERLANDS ANTILLES (N/A)",
      NC => "NEW CALEDONIA (N/A)",
      NZ => "NEW ZEALAND (3.1)",
      NI => "NICARAGUA (3.1)",
      NE => "NIGER (N/A)",
      NG => "NIGERIA (3.2)",
      NU => "NIUE (N/A)",
      XX => "NON MEMBERS COUNTRIES (3.2)",
      NF => "NORFOLK ISLAND (N/A)",
      MP => "NORTHERN MARIANA ISLANDS (N/A)",
      NO => "NORWAY (3.1)",
      OM => "OMAN (3.2)",
      PK => "PAKISTAN (3.2)",
      PW => "PALAU (N/A)",
      PS => "PALESTINIAN TERRITORY (N/A)",
      PA => "PANAMA (3.2)",
      PG => "PAPUA NEW GUINEA (3.2)",
      PY => "PARAGUAY (N/A)",
      PE => "PERU (3.1)",
      PH => "PHILIPPINES (2.0)",
      PN => "PITCAIRN ISLAND (N/A)",
      PL => "POLAND (3.1)",
      PT => "PORTUGAL (3.2)",
      PR => "PUERTO RICO (N/A)",
      QA => "QATAR (3.2)",
      RE => "REUNION (N/A)",
      RO => "ROMANIA (3.1)",
      RU => "RUSSIA (3.1)",
      RW => "RWANDA (N/A)",
      SH => "SAINT HELENA (N/A)",
      KN => "SAINT KITTS AND NEVIS (N/A)",
      LC => "SAINT LUCIA (3.2)",
      PM => "SAINT PIERRE AND MIQUELON (N/A)",
      VC => "SAINT VINCENT AND THE GRENADINES (N/A)",
      WS => "SAMOA (3.2)",
      SM => "SAN MARINO (N/A)",
      ST => "SAO TOME AND PRINCIPE (N/A)",
      SA => "SAUDI ARABIA (3.2)",
      SN => "SENEGAL (3.2)",
      RS => "SERBIA (3.2)",
      SC => "SEYCHELLES (3.2)",
      SL => "SIERRA LEONE (N/A)",
      SG => "SINGAPORE (3.0)",
      SK => "SLOVAKIA (3.1)",
      SI => "SLOVENIA (3.2)",
      SB => "SOLOMON ISLANDS (N/A)",
      SO => "SOMALIA (N/A)",
      ZA => "SOUTH AFRICA (3.0)",
      GS => "SOUTH GEORGIA AND THE SOUTH SANDWICH ISLANDS (N/A)",
      ES => "SPAIN (3.1)",
      LK => "SRI LANKA (N/A)",
      SD => "SUDAN (3.2)",
      SR => "SURINAME (3.2)",
      SJ => "SVALBARD AND JAN MAYEN ISLANDS (N/A)",
      SZ => "SWAZILAND (3.2)",
      SE => "SWEDEN (3.1)",
      CH => "SWITZERLAND (3.1)",
      SY => "SYRIA (3.2)",
      TW => "TAIWAN (3.1)",
      TJ => "TAJIKISTAN (3.2)",
      TZ => "TANZANIA (3.2)",
      TH => "THAILAND (3.2)",
      TG => "TOGO (3.2)",
      TK => "TOKELAU (N/A)",
      TO => "TONGA (N/A)",
      TT => "TRINIDAD AND TOBAGO (3.2)",
      TN => "TUNISIA (3.2)",
      TR => "TURKEY (2.0)",
      TM => "TURKMENISTAN (3.2)",
      TC => "TURKS AND CAICOS ISLANDS (3.2)",
      TV => "TUVALU (N/A)",
      UG => "UGANDA (3.2)",
      UA => "UKRAINE (2.0)",
      AE => "UNITED ARAB EMIRATES (3.2)",
      GB => "UNITED KINGDOM (2.0)",
      US => "UNITED STATES (3.0)",
      UM => "UNITED STATES MINOR OUTLYING ISLANDS (N/A)",
      UY => "URUGUAY (2.0)",
      UZ => "UZBEKISTAN (3.0)",
      VU => "VANUATU (3.2)",
      VA => "VATICAN CITY STATE (N/A)",
      VE => "VENEZUELA (3.2)",
      VN => "VIETNAM (3.1)",
      VG => "VIRGIN ISLANDS (BRITISH) (3.2)",
      VI => "VIRGIN ISLANDS (US) (N/A)",
      WF => "WALLIS AND FUTUNA ISLANDS (N/A)",
      EH => "WESTERN SAHARA (N/A)",
      YE => "YEMEN (3.2)",
      ZM => "ZAMBIA (3.2)",
      ZW => "ZIMBABWE (3.2)",
     });
  $self->iDdlCountryList({});
  foreach my $key (keys %{$self->DdlCountryList}) {
    $self->iDdlCountryList->{$self->DdlCountryList->{$key}} = $key;
  }
}

sub CacheResults {
  my ($self,%args) = @_;
  # we want to cache the results of a given search, both in terms of
  # the search and the result, and then add the individual results to
  # a copy of GEPIR we keep locally
  my @res = $self->MySayer->ExecuteCodeOnData
    (
     GiveHasResult => $args{GiveHasResult},
     CodeRef => sub {
       my $self = $UNIVERSAL::systemwwwgepir;
       $self->SearchByName
	 (
	  CompanyName => $_[0]->{CompanyName},
	  Country => $_[0]->{Country},
	 );
     },
     Data => [{
	       CompanyName => $args{CompanyName},
	       Country => $args{Country},
	      }],
     Overwrite => $args{Overwrite},
     NoRetrieve => $args{NoRetrieve},
     Skip => $args{Skip},
    );
  if ($res[0]->{Success}) {
    return $res[0]->{Result};
  } else {
    return
      {
       Success => 0,
      };
  }
}

1;
