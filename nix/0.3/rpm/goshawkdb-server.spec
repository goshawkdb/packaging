Summary: GoshawkDB distributed data store server
Name: goshawkdb-server
Version: 0.3
Release: 1
Group: Applications/Databases
License: AGPLv3
SOURCE0: %{buildroot}/%{name}-%{version}.tar.xz
Packager: Matthew Sackman <matthew@goshawkdb.io>
URL: https://goshawkdb.io/

%description
GoshawkDB is a distributed, transactional, fault-tolerant object
store. It supports full general purpose transactions with
strong-serializability isolation only. It is a CP system with
configurable tolerance to failure. It is a schema-less data store,
which supports automatic sharding of data and is horizontally
scalable.


%prep
%setup -q

%build
# Empty section.

%install
rm -rf %{buildroot}
mkdir -p  %{buildroot}%{_bindir}
mv bin $(dirname %{buildroot}%{_bindir})

for t in $(find %{buildroot} -depth); do
  touch -ad '%{timestamp}' $t
  touch -md '%{timestamp}' $t
done

touch -ad '%{timestamp}' LICENSE
touch -md '%{timestamp}' LICENSE

%clean
rm -rf %{buildroot}

%files
%defattr(-,root,root,-)
%doc LICENSE
%{_bindir}/consistencychecker
%{_bindir}/goshawkdb


%changelog
* Fri Nov 18 2016  Matthew Sackman <matthew@goshawkdb.io> 0.3-1
- New upstream release

* Fri May 06 2016  Matthew Sackman <matthew@goshawkdb.io> 0.2-1
- New upstream release

* Fri Dec 18 2015  Matthew Sackman <matthew@goshawkdb.io> 0.1-1
- Initial release

EOF
