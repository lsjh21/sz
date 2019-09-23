#!/usr/bin/perl -n
BEGIN {
  use strict;
  use warnings 'all';
  use File::Find;

  my $dir = shift
    or die "Supply sample directory to use as first argument\n";
  $#ARGV == -1
    or die "Unexpected argument(s): @ARGV\n";

  chdir $dir or die "?Cannot change directory\n";

  find(sub {
    m(^(?:.*\.(?:java|js|cpp|cs|m|html|xaml|py)|pom\.xml)$) &&
    push @ARGV, substr($File::Find::name, 2);
  }, '.');

  our $c_s = qr(^\s*// <(\w+)>);
  our $c_e = qr(^\s*// </(\w+)>);
  our $xml_s = qr(^\s*<!-- <(\w+)> -->);
  our $xml_e = qr(^\s*<!-- </(\w+)> -->);
  our $py_s = qr(^\s*# <(\w+)>);
  our $py_e = qr(^\s*# </(\w+)>);
  our $err = 0;

  our @expectedFiles;

  # Lists of files that are referenced (included) from azure-docs.
  # Note: case must match the one in the repository.
  #
  # IMPORTANT - before updating this list talk to wolfma/zhouwang/mahilleb.
  @expectedFiles = map qw(
    quickstart/java-android/app/src/main/res/layout/activity_main.xml
    quickstart/js-browser/token.php
    quickstart/objectivec-ios/helloworld/helloworld/Base.lproj/Main.storyboard
    quickstart/objectivec-macos/helloworld/Podfile
    quickstart/swift-ios/helloworld/Podfile
    quickstart/swift-macos/helloworld/Podfile
    quickstart/text-to-speech/java-android/app/src/main/res/layout/activity_main.xml
    quickstart/text-to-speech/objectivec-ios/helloworld/Podfile
    quickstart/text-to-speech/objectivec-macos/helloworld/Podfile
    quickstart/text-to-speech/swift-ios/helloworld/Podfile
    quickstart/text-to-speech/swift-macos/helloworld/Podfile
  );

  my @expectedTags;

  {
    no warnings 'qw'; # suppress warnings about comment in qw() below

    # Sorted list of files + tags that are referenced (included) from azure-docs
    # IMPORTANT - before updating this list talk to wolfma/zhouwang/mahilleb.
    @expectedTags = map { m/^([^#]+)#([^#]+)$/ or die "misconfigured $_\n"; (lc $1) . "#$2"  } qw(
      quickstart/cpp-linux/helloworld.cpp#code
      quickstart/cpp-macos/helloworld.cpp#code
      quickstart/cpp-windows/helloworld/helloworld.cpp#code
      quickstart/csharp-dotnet-windows/helloworld/Program.cs#code
      quickstart/csharp-dotnetcore/helloworld/Program.cs#code
      quickstart/csharp-unity/Assets/Scripts/HelloWorld.cs#code
      quickstart/csharp-uwp/helloworld/MainPage.xaml#StackPanel
      quickstart/csharp-uwp/helloworld/MainPage.xaml.cs#code
      quickstart/java-android/app/src/main/java/com/microsoft/cognitiveservices/speech/samples/quickstart/MainActivity.java#code
      quickstart/java-jre/pom.xml#dependencies
      quickstart/java-jre/pom.xml#repositories
      quickstart/java-jre/src/speechsdk/quickstart/Main.java#code
      quickstart/js-browser/index.html#authorizationfunction
      quickstart/js-browser/index.html#quickstartcode
      quickstart/js-browser/index.html#speechsdkref
      quickstart/js-browser/index.html#uidiv
      quickstart/js-node/index.js#code
      quickstart/objectivec-ios/helloworld/helloworld/ViewController.m#code
      quickstart/objectivec-macos/helloworld/helloworld/AppDelegate.m#code
      quickstart/python/quickstart.py#code
      quickstart/speech-translation/cpp-windows/helloworld/helloworld.cpp#code
      quickstart/speech-translation/csharp-dotnet-windows/helloworld/Program.cs#code
      quickstart/speech-translation/csharp-dotnetcore/helloworld/Program.cs#code
      quickstart/speech-translation/csharp-uwp/helloworld/MainPage.xaml#StackPanel
      quickstart/speech-translation/csharp-uwp/helloworld/MainPage.xaml.cs#code
      quickstart/speech-translation/java-jre/src/speechsdk/quickstart/Main.java#code
      quickstart/swift-ios/helloworld/helloworld/AppDelegate.swift#code
      quickstart/swift-ios/helloworld/helloworld/MicrosoftCognitiveServicesSpeech-Bridging-Header.h#code
      quickstart/swift-ios/helloworld/helloworld/ViewController.swift#code
      quickstart/swift-macos/helloworld/helloworld/AppDelegate.swift#code
      quickstart/swift-macos/helloworld/helloworld/MicrosoftCognitiveServicesSpeech-Bridging-Header.h#code
      quickstart/text-to-speech/cpp-linux/helloworld.cpp#code
      quickstart/text-to-speech/cpp-macos/helloworld.cpp#code
      quickstart/text-to-speech/cpp-windows/helloworld/helloworld.cpp#code
      quickstart/text-to-speech/csharp-dotnet-windows/helloworld/Program.cs#code
      quickstart/text-to-speech/csharp-dotnetcore/helloworld/Program.cs#code
      quickstart/text-to-speech/csharp-unity/Assets/Scripts/HelloWorld.cs#code
      quickstart/text-to-speech/csharp-uwp/helloworld/MainPage.xaml#StackPanel
      quickstart/text-to-speech/csharp-uwp/helloworld/MainPage.xaml.cs#code
      quickstart/text-to-speech/java-android/app/src/main/java/com/microsoft/cognitiveservices/speech/samples/quickstart/MainActivity.java#code
      quickstart/text-to-speech/java-android/app/src/main/java/com/microsoft/cognitiveservices/speech/samples/quickstart/SpeakerStream.java#code
      quickstart/text-to-speech/java-jre/pom.xml#dependencies
      quickstart/text-to-speech/java-jre/pom.xml#repositories
      quickstart/text-to-speech/java-jre/src/speechsdk/quickstart/Main.java#code
      quickstart/text-to-speech/objectivec-ios/helloworld/helloworld/AppDelegate.m#code
      quickstart/text-to-speech/objectivec-ios/helloworld/helloworld/ViewController.m#code
      quickstart/text-to-speech/objectivec-macos/helloworld/helloworld/AppDelegate.m#code
      quickstart/text-to-speech/python/quickstart.py#code
      quickstart/text-to-speech/swift-ios/helloworld/helloworld/AppDelegate.swift#code
      quickstart/text-to-speech/swift-ios/helloworld/helloworld/MicrosoftCognitiveServicesSpeech-Bridging-Header.h#code
      quickstart/text-to-speech/swift-ios/helloworld/helloworld/ViewController.swift#code
      quickstart/text-to-speech/swift-macos/helloworld/helloworld/AppDelegate.swift#code
      quickstart/text-to-speech/swift-macos/helloworld/helloworld/MicrosoftCognitiveServicesSpeech-Bridging-Header.h#code
      quickstart/virtual-assistant/java-jre/pom.xml#dependencies
      quickstart/virtual-assistant/java-jre/src/com/speechsdk/quickstart/ActivityAudioStream.java#code
      quickstart/virtual-assistant/java-jre/src/com/speechsdk/quickstart/Main.java#code
      samples/batch/csharp/program.cs#batchdefinition
      samples/batch/csharp/program.cs#batchstatus
      samples/cpp/windows/console/samples/intent_recognition_samples.cpp#IntentContinuousRecognitionWithFile
      samples/cpp/windows/console/samples/intent_recognition_samples.cpp#IntentRecognitionWithLanguage
      samples/cpp/windows/console/samples/intent_recognition_samples.cpp#IntentRecognitionWithMicrophone
      samples/cpp/windows/console/samples/intent_recognition_samples.cpp#toplevel
      samples/cpp/windows/console/samples/speech_recognition_samples.cpp#SpeechContinuousRecognitionWithFile
      samples/cpp/windows/console/samples/speech_recognition_samples.cpp#SpeechRecognitionUsingCustomizedModel
      samples/cpp/windows/console/samples/speech_recognition_samples.cpp#SpeechRecognitionWithMicrophone
      samples/cpp/windows/console/samples/speech_recognition_samples.cpp#toplevel
      samples/cpp/windows/console/samples/translation_samples.cpp#TranslationWithMicrophone
      samples/cpp/windows/console/samples/translation_samples.cpp#toplevel
      samples/csharp/sharedcontent/console/intent_recognition_samples.cs#intentContinuousRecognitionWithFile
      samples/csharp/sharedcontent/console/intent_recognition_samples.cs#intentRecognitionWithMicrophone
      samples/csharp/sharedcontent/console/intent_recognition_samples.cs#toplevel
      samples/csharp/sharedcontent/console/speech_recognition_samples.cs#recognitionContinuousWithFile
      samples/csharp/sharedcontent/console/speech_recognition_samples.cs#recognitionCustomized
      samples/csharp/sharedcontent/console/speech_recognition_samples.cs#recognitionWithMicrophone
      samples/csharp/sharedcontent/console/speech_recognition_samples.cs#toplevel
      samples/csharp/sharedcontent/console/translation_samples.cs#TranslationWithFileAsync
      samples/csharp/sharedcontent/console/translation_samples.cs#TranslationWithMicrophoneAsync
      samples/csharp/sharedcontent/console/translation_samples.cs#toplevel
      samples/java/jre/console/src/com/microsoft/cognitiveservices/speech/samples/console/IntentRecognitionSamples.java#IntentContinuousRecognitionWithFile
      samples/java/jre/console/src/com/microsoft/cognitiveservices/speech/samples/console/IntentRecognitionSamples.java#IntentRecognitionWithLanguage
      samples/java/jre/console/src/com/microsoft/cognitiveservices/speech/samples/console/IntentRecognitionSamples.java#IntentRecognitionWithMicrophone
      samples/java/jre/console/src/com/microsoft/cognitiveservices/speech/samples/console/IntentRecognitionSamples.java#toplevel
      samples/java/jre/console/src/com/microsoft/cognitiveservices/speech/samples/console/SpeechRecognitionSamples.java#recognitionContinuousWithFile
      samples/java/jre/console/src/com/microsoft/cognitiveservices/speech/samples/console/SpeechRecognitionSamples.java#recognitionCustomized
      samples/java/jre/console/src/com/microsoft/cognitiveservices/speech/samples/console/SpeechRecognitionSamples.java#recognitionWithMicrophone
      samples/java/jre/console/src/com/microsoft/cognitiveservices/speech/samples/console/SpeechRecognitionSamples.java#toplevel
      samples/java/jre/console/src/com/microsoft/cognitiveservices/speech/samples/console/TranslationSamples.java#TranslationWithFileAsync
      samples/java/jre/console/src/com/microsoft/cognitiveservices/speech/samples/console/TranslationSamples.java#TranslationWithMicrophoneAsync
      samples/java/jre/console/src/com/microsoft/cognitiveservices/speech/samples/console/TranslationSamples.java#toplevel
      samples/objective-c/ios/compressed-streams/CompressedStreamsSample/CompressedStreamsSample/ViewController.m#setup-stream
      samples/objective-c/ios/compressed-streams/CompressedStreamsSample/CompressedStreamsSample/ViewController.m#push-compressed-stream
      samples/python/console/intent_sample.py#IntentContinuousRecognitionWithFile
      samples/python/console/intent_sample.py#IntentRecognitionOnceWithFile
      samples/python/console/intent_sample.py#IntentRecognitionOnceWithMic
      samples/python/console/speech_sample.py#SpeechContinuousRecognitionWithFile
      samples/python/console/speech_sample.py#SpeechRecognitionUsingCustomizedModel
      samples/python/console/speech_sample.py#SpeechRecognitionWithFile
      samples/python/console/speech_sample.py#SpeechRecognitionWithMicrophone
      samples/python/console/translation_sample.py#TranslationContinuous
      samples/python/console/translation_sample.py#TranslationOnceWithFile
      samples/python/console/translation_sample.py#TranslationOnceWithMic
    );
  }

  our %expectedCount = map { $_ => 0 } @expectedTags;
}
sub ateof() {
  if (defined $m) {
    warn "DocFx codetags: tag $m not closed at end of file $oldargv.\n";
    $err++
  }
}
if ($ARGV ne $oldargv) {
  $. = 1;
  ateof();
  $oldargv = $ARGV;
  $m = undef;

  if ($ARGV =~ /\.xa?ml$|\.html$/) {
    $s = $xml_s;
    $e = $xml_e;
  } elsif ($ARGV =~ /\.py$/) {
    $s = $py_s;
    $e = $py_e;
  } else {
    $s = $c_s;
    $e = $c_e;
  }
}

if (defined $m) {
  if (m/$s/) {
    warn "DocFx codetags: nested tag $1 not supported in file $ARGV, line $.\n";
    $m = $1;
    $err++
  }
  if (m/$e/) {
    if ($1 ne $m) {
      warn "DocFx codetags: Unmatched tag $1 in file $ARGV, line $.\n";
      $err++
    }
    $m = undef;
  }
} else {
  if (m/$s/) {
    $m = $1;

    my $id = (lc $ARGV). "#$1";
    if (exists $expectedCount{$id}) {
      if ($expectedCount{$id} != 0) {
        warn "DocFx codetags: duplicate tag $1 in file $ARGV, line $.\n";
        $err++;
      }
      $expectedCount{$id}++;
    } else {
      warn "DocFx codetags: unexpected tag $1 in file $ARGV, line $.; contact wolfma/zhouwang/mahilleb\n";
      $err++;
    }
  }
  if (m/$e/) {
    warn "DocFx codetags: Unexpected end tag $1 in file $ARGV, line $.\n";
    $err++
  }
}

END {
  ateof();

  # Check links that haven't been found
  for my $id (keys %expectedCount) {
    if ($expectedCount{$id} == 0) {
      warn "DocFx codetags: tag $id was expected, but not found; contact wolfma/zhouwang/mahilleb\n";
    }
  }

  # Verify mandatory files are present
  for my $file (@expectedFiles) {
    -r "$file" or do {
      warn "DocFx codetags: file $file must exist, but not found; contact wolfma/zhouwang/mahilleb\n";
      $err++;
    }
  }

  exit 1 if $err > 0;
}
